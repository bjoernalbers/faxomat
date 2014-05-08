require 'spec_helper'

describe Delivery do
  let(:delivery) { build(:delivery) }

  it 'belongs to a fax' do
    fax = create(:fax)
    delivery = build(:delivery, fax: fax)
    expect(delivery.fax).to eq fax
  end

  context 'without a fax' do
    let(:delivery) { build(:delivery, fax: nil) }

    it 'is invalid' do
      expect(delivery).to have(1).errors_on(:fax)
    end

    it 'can not be saved in the database' do
      expect { delivery.save(validate: false) }.to raise_error
    end
  end

  context 'without a print_job_id' do
    let(:delivery) { build(:delivery, print_job_id: nil) }

    it 'is valid because we set it after validations' do
      expect(delivery).to be_valid #have(1).errors_on(:print_job_id)
    end

    it 'can not be saved in the database' do
      expect { delivery.save(validate: false) }.to raise_error
    end
  end

  it 'validates the uniqueness of the print_job_id' do
    delivery = create(:delivery)
    expect {
      create(:delivery, print_job_id: delivery.print_job_id)
    }.to raise_error ActiveRecord::RecordNotUnique
  end

  it 'has a factory that builds objects with unique print_job_id' do
    2.times {
      expect { create(:delivery) }.to_not raise_error
    }
  end

  describe '#print_job' do
    let(:print_job) { double('print_job', :title= => nil) }
    let(:fax) { create(:fax) }
    let(:delivery) { build(:delivery, fax: fax) }

    before do
      Cups::PrintJob.stub(:new).and_return(print_job)
    end

    it 'initializes a print job with the fax attributes' do
      fax.stub(:path).and_return('chunky.pdf')
      delivery.stub(:phone).and_return('42')
      delivery.send(:print_job)
      expect(Cups::PrintJob).to have_received(:new).
        with('chunky.pdf', 'Fax', {'phone' => '42'})
    end

    it 'returns the instance' do
      expect(delivery.send(:print_job)).to eq print_job
    end

    it 'caches the instance' do
      2.times { delivery.send(:print_job) }
      expect(Cups::PrintJob).to have_received(:new).once
    end

    it 'sets the print job title' do
      fax.stub(:title).and_return('chunky bacon')
      delivery.send(:print_job)
      expect(print_job).to have_received(:title=).with(fax.title)
    end
  end

  describe '#run!' do
    let(:print_job) { double('print_job', print: true, job_id: 23) }

    before do
      delivery.stub(:print_job).and_return(print_job)
    end

    it 'gets called on create' do
      delivery.stub(:run!)
      delivery.save
      expect(delivery).to have_received(:run!)
    end

    it 'does not get called on update' do
      delivery = create(:delivery)
      delivery.stub(:run!)
      delivery.save
      expect(delivery).to_not have_received(:run!)
    end

    context 'without print_job_id' do
      before do
        delivery.stub(:print_job_id).and_return(nil)
        delivery.stub(:update!)
      end

      it 'delivers the print job' do
        delivery.send(:run!)
        expect(print_job).to have_received(:print)
      end

      it 'updates the print_job_id with the print job id' do
        expect(delivery.print_job_id).to be_nil
        delivery.send(:run!)
        expect(delivery).to have_received(:update!).
          with(print_job_id: print_job.job_id)
      end

      it 'fails on printer errors' do
        print_job.stub(:print).and_return(false)
        expect { delivery.send(:run!) }.to raise_error
      end
    end

    context 'with print_job_id' do
      before do
        delivery.stub(:print_job_id).and_return(23)
        delivery.stub(:update!)
      end

      it 'does not deliver again' do
        delivery.send(:run!)
        expect(print_job).to_not have_received(:print)
      end

      it 'does not update the print_job_id' do
        delivery.send(:run!)
        expect(delivery).to_not have_received(:update!)
      end
    end
  end

  describe '#phone' do
    it 'returns the phone number with dialout prefix' do
      fax = double('fax', phone: '0123456789')
      delivery.stub(:fax).and_return(fax)
      expect(delivery.send(:phone)).to eq '00123456789'
    end
  end
end
