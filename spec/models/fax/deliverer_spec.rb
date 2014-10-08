require 'spec_helper'

describe Fax::Deliverer do
  let(:fax) { double('fax') }
  let(:deliverer) { Fax::Deliverer.new(fax) }

  describe '.deliver' do
    before do
      allow(Fax::Deliverer).to receive(:deliverable).and_return([fax, fax])
      allow(fax).to receive(:deliver)
      Fax::Deliverer.deliver
    end

    it 'queries all deliverable faxes' do
      expect(Fax::Deliverer).to have_received(:deliverable)
    end

    it 'delivers each matching fax' do
      expect(fax).to have_received(:deliver).twice
    end
  end

  describe '.deliverable' do
    let(:fax) { create(:fax) }

    it 'includes faxes without print_job_id' do
      fax.update(print_job_id: nil)
      expect(Fax::Deliverer.deliverable).to match_array([ fax ])
    end

    it 'includes aborted faxes' do
      fax.update(state: 'aborted')
      expect(Fax::Deliverer.deliverable).to match_array([ fax ])
    end

    it 'does not include completed faxes' do
      fax.update(state: 'completed')
      expect(Fax::Deliverer.deliverable).to be_empty
    end

    it 'does not include currently being delivered faxes' do
      fax.update(state: 'chunky bacon', print_job_id: 42)
      expect(Fax::Deliverer.deliverable).to be_empty
    end

    it 'does not include faxes that are older then 4 days' do
      fax.update(print_job_id: nil, created_at: Time.zone.now-5.days)
      expect(Fax::Deliverer.deliverable).to be_empty
    end

    it 'includes faxes that are younger then 5 days' do
      fax.update(print_job_id: nil, created_at: Time.zone.now-4.days)
      expect(Fax::Deliverer.deliverable).to match_array([ fax ])
    end

    it 'orders faxes by creation date (fifo)' do
      old = create(:fax, print_job_id: nil)
      new = create(:fax, print_job_id: nil)
      expect(old.created_at).to be < new.created_at
      expect(old.updated_at).to be < new.updated_at
      expect(Fax::Deliverer.deliverable.to_a).to eq [ old, new ]
    end
  end

  describe '.check' do
    let(:fax) { create(:fax, print_job_id: 1, state: :pending) }
    let(:print_jobs) { {} }

    before do
      allow(fax).to receive(:update)
      allow(Fax).to receive(:find_by).and_return(fax)
      allow(Cups).to receive(:all_jobs).and_return(print_jobs)
    end

    it 'updates the fax when state has changed' do
      print_jobs[1] = {state: :chunky}
      Fax::Deliverer.check
      expect(fax).to have_received(:update).with(state: 'chunky')
    end

    it 'does not update the fax when state is unchanged' do
      print_jobs[1] = {state: :pending}
      Fax::Deliverer.check
      expect(fax).to_not have_received(:update)
    end

    it 'queries CUPS print job states for the right printer' do
      Fax::Deliverer.check
      expect(Cups).to have_received(:all_jobs).with('Fax')
    end

    it 'finds synchronizes fax states by their print job id' do
      print_jobs[1] = {state: :chunky}
      Fax::Deliverer.check
      expect(Fax).to have_received(:find_by).with(print_job_id: 1)
    end

    it 'handles unknown print job ids' do
      allow(Fax).to receive(:find_by).and_return(nil)
      expect{ Fax::Deliverer.check }.to_not raise_error
    end

    it 'handles print job without a state' do
      print_jobs[1] = {}
      expect{ Fax::Deliverer.check }.to_not raise_error
    end
  end

  describe '#deliver' do
    before do
      allow(deliverer).to receive(:deliver!)
    end

    context 'with a default fax from factory_girl' do
      let(:fax) { build(:fax) }

      it 'does not deliver' do
        deliverer.deliver
        expect(deliverer).to_not have_received(:deliver!)
      end
    end

    context 'with a completed fax from factory_girl' do
      let(:fax) { build(:completed_fax) }

      it 'does not deliver' do
        deliverer.deliver
        expect(deliverer).to_not have_received(:deliver!)
      end
    end

    context 'with undeliverable fax' do
      before do
        allow(deliverer).to receive(:deliverable?).and_return(false)
        deliverer.deliver
      end

      it 'does not deliver' do
        expect(deliverer).to_not have_received(:deliver!)
      end
    end

    context 'with deliverable fax' do
      before do
        expect(deliverer).to receive(:deliverable?).and_return(true)
        deliverer.deliver
      end

      it 'delivers' do
        expect(deliverer).to have_received(:deliver!)
      end
    end
  end

  describe '#deliver!' do
    let(:print_job) { double('print_job') }

    before do
      allow(print_job).to receive(:print).and_return(true)
      allow(print_job).to receive(:job_id).and_return(23)
      allow(deliverer).to receive(:print_job).and_return(print_job)
      allow(fax).to receive(:update)
      allow(fax).to receive(:delivery_attempts).and_return(nil, 1)

      deliverer.send(:deliver!)
    end

    it 'prints the print job' do
      expect(print_job).to have_received(:print)
    end

    it 'saves the print job id and increments the delivery attempts' do
      expect(fax).to have_received(:update).
        with(print_job_id: print_job.job_id, delivery_attempts: 1)
      deliverer.send(:deliver!)
      expect(fax).to have_received(:update).
        with(print_job_id: print_job.job_id, delivery_attempts: 2)
    end

    context 'when printing fails' do
      before do
        allow(print_job).to receive(:print).and_return(false)
      end

      it 'raises an error' do
        expect{
          deliverer.send(:deliver!)
        }.to raise_error /could not be delivered/i
      end
    end
  end

  describe '#deliverable?' do
    before do
      allow(fax).to receive(:print_job_id)
      allow(fax).to receive(:state)
    end

    context 'with unprinted fax' do
      before do
        allow(fax).to receive(:print_job_id).and_return(nil)
      end

      it 'is true' do
        expect(deliverer.send(:deliverable?)).to be_true
      end
    end

    context 'with printed fax' do
      before do
        allow(fax).to receive(:print_job_id).and_return(23)
      end

      it 'is true when aborted' do
        allow(fax).to receive(:state).and_return('aborted')
        expect(deliverer.send(:deliverable?)).to be_true
      end

      it 'is false when not aborted' do
        allow(fax).to receive(:state).and_return('chunky bacon')
        expect(deliverer.send(:deliverable?)).to be_false
      end
    end
  end

  describe '#print_job' do
    let(:print_job) { double('print_job') }

    before do
      allow(Cups::PrintJob).to receive(:new).and_return(print_job)
      allow(print_job).to receive(:title=)
      allow(fax).to receive(:path).and_return('chunky.pdf')
      allow(fax).to receive(:title).and_return('chunky bacon')
      allow(deliverer).to receive(:phone).and_return('123')
    end

    it 'initializes a print job' do
      deliverer.send(:print_job)
      expect(Cups::PrintJob).to have_received(:new).
        with('chunky.pdf', 'Fax', {'phone' => '123'})
    end

    it 'returns the instance' do
      expect(deliverer.send(:print_job)).to eq print_job
    end

    it 'caches the instance' do
      2.times { deliverer.send(:print_job) }
      expect(Cups::PrintJob).to have_received(:new).once
    end

    it 'sets the print job title' do
      deliverer.send(:print_job)
      expect(print_job).to have_received(:title=).with('chunky bacon')
    end
  end

  describe '#phone' do
    it 'returns the joined dialout prefix and recipient phone' do
      expect(fax).to receive(:phone).and_return('42')
      expect(Rails.application.config).to receive(:dialout_prefix).and_return('0')
      expect(deliverer.send(:phone)).to eq('042')
    end
  end
end
