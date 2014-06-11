require 'spec_helper'

describe Fax do
  let(:fax) { build(:fax) }

  it 'validates that path points to an existing file' do
    pending
  end

  it 'orders faxes by default by descending creation date' do
    now = DateTime.current
    old_fax = create(:fax, created_at: now-1.day)
    new_fax = create(:fax, created_at: now)

    faxes = Fax.all

    expect(faxes.first).to eq(new_fax)
    expect(faxes.last).to eq(old_fax)
  end

  context 'without a path' do
    let(:fax) { build(:fax, path: nil) }

    it 'is invalid' do
      expect(fax).to be_invalid
      expect(fax).to have(1).errors_on(:path)
    end

    it 'can not be saved in the database' do
      expect { fax.save!(validate: false) }.to raise_error
    end
  end

  context 'without a recipient' do
    let(:fax) { build(:fax, recipient: nil) }

    it 'is invalid' do
      expect(fax).to be_invalid
      expect(fax).to have(1).errors_on(:recipient)
    end

    it 'can not be saved in the database' do
      expect { fax.save!(validate: false) }.to raise_error
    end
  end

  context 'without a patient' do
    let(:fax) { build(:fax, patient: nil) }

    it 'is invalid' do
      expect(fax).to be_invalid
      expect(fax).to have(1).errors_on(:patient)
    end

    it 'can not be saved in the database' do
      expect { fax.save!(validate: false) }.to raise_error
    end
  end

  context 'without unique print_job_id' do
    let(:other_fax) { create(:fax, print_job_id: 5) }
    let(:fax) { build(:fax, print_job_id: other_fax.print_job_id) }

    it 'is invalid' do
      expect(fax).to have(1).errors_on(:print_job_id)
    end

    it 'can not be saved in the database' do
      expect {
        fax.save(validate: false)
      }.to raise_error ActiveRecord::RecordNotUnique
    end
  end

  context 'without print_job_id' do
    let(:fax) { build(:fax, print_job_id: nil) }

    it 'is valid' do
      expect(fax).to be_valid
    end

    it 'can be saved in the database' do
      expect {
        fax.save(validate: false)
      }.to_not raise_error ActiveRecord::RecordNotUnique
    end

    it 'can be saved even with other null print_job_ids' do
      2.times {
        expect { create(:fax, print_job_id: nil) }.to_not raise_error
      }
    end
  end

  describe '.created_today' do
    let(:now) { DateTime.current }

    it 'returns today created faxes' do
      fax = create(:fax, created_at: now.beginning_of_day)
      expect(Fax.created_today).to include(fax)
    end

    it 'does not return faxes created before today' do
      fax = create(:fax, created_at: now.beginning_of_day-1.second)
      expect(Fax.created_today).to_not include(fax)
    end
  end

  describe '.deliver' do
    before do
      allow(Fax).to receive(:undelivered).and_return( [fax] )
      allow(fax).to receive(:deliver)
    end

    it 'processes only undelivered faxes' do
      Fax.deliver
      expect(Fax).to have_received(:undelivered)
    end

    it 'delivers each fax' do
      Fax.deliver
      expect(fax).to have_received(:deliver)
    end

    it 'returns all delivered faxes' do
      expect(Fax.deliver).to eq( [fax] )
    end
  end

  describe '.undelivered' do
    before do
      Fax.delete_all #TODO: Fix specs and remove this hack!
    end

    it 'includes faxes without print job id' do
      fax.update!(print_job_id: nil)
      expect(Fax.undelivered).to match_array([fax])
    end

    it 'excludes faxes with print job id' do
      fax.update!(print_job_id: 23)
      expect(Fax.undelivered).to be_empty
    end
  end

  describe '#update_states' do
    let(:print_jobs) { {} }

    before do
      Cups.stub(:all_jobs).and_return(print_jobs)
    end

    it 'updates the state for each matching delivery' do
      fax = create(:fax, print_job_id: 1)
      print_jobs[1] = {:state => :chunky}
      expect(fax.state).to_not eq('chunky')
      Fax.update_states
      fax.reload
      expect(fax.state).to eq('chunky')
    end

    it 'queries the jobs states via CUPS' do
      Fax.update_states
      expect(Cups).to have_received(:all_jobs).with('Fax')
    end

    it 'handles unknown print jobs' do
      print_jobs[1] = {:state => :chunky}
      expect {
        Fax.update_states
      }.to_not raise_error
    end

    it 'handles missing states' do
      fax = create(:fax, print_job_id: 1)
      print_jobs[1] = {}
      expect {
        Fax.update_states
      }.to_not raise_error
    end
  end

  describe '.aborted' do
    it 'returns aborted faxes' do
      fax.update(state: 'aborted')
      expect(Fax.aborted).to match_array([fax])
    end

    it 'does not return faxes in other states' do
      create(:fax, state:'completed')
      create(:fax)
      create(:fax, state:'funky')
      expect(Fax.aborted).to be_empty
    end
  end

  describe '.search' do
    let!(:patient) { create(:patient,
                            first_name: 'Bruce',
                            last_name: 'Willis',
                            date_of_birth: '1955-03-19') }
    let!(:recipient) { create(:recipient,
                              phone: '0987654321') }
    let!(:fax) { create(:fax, patient: patient, recipient: recipient) }
    let!(:other_fax) { create(:fax) }

    it 'searches by patient date of birth' do
      %w(19.3.1955 19.3.1955).each do |query|
        expect(Fax.search(query)).to match_array [fax]
      end
    end

    it 'searches by patient last name' do
      %w(Willis willis illi).each do |query|
        expect(Fax.search(query)).to match_array [fax]
      end
    end

    it 'handles german umlauts' do
      patient = create(:patient, first_name: 'Björn')
      fax = create(:fax, patient: patient)
      expect(Fax.search('Björn')).to match_array [fax]
    end

    it 'searches by patient first name' do
      %w(Bruce bruce ruc).each do |query|
        expect(Fax.search(query)).to match_array [fax]
      end
    end

    it 'searches by date of birth and name' do
      expect(Fax.search('chuck 19.3.1955')).to be_empty
      expect(Fax.search('bruce 19.3.1955')).to match_array [fax]
    end

    it 'searches by multiple patient names' do
      expect(Fax.search('willis chuck')).to be_empty
      expect(Fax.search('willis bruce')).to match_array [fax]
    end

    it 'searches by recipient phone number' do
      expect(Fax.search('8765')).to match_array [fax]
    end

    it 'does not search with blank query' do
      [nil, ''].each do |query|
        expect(Fax.search(query)).to be_empty
      end
    end
  end

  describe '#phone' do
    it 'returns the recipients phone number' do
      recipient = create(:recipient, phone: '0123456789')
      fax = create(:fax, recipient: recipient)
      expect(fax.phone).to eq recipient.phone
    end
  end

  it 'has many deliveries' do
    expect(fax).to respond_to(:deliveries)
  end

  it 'destroys dependend deliveries' do
    fax = create(:fax)
    2.times { create(:delivery, fax: fax) }
    expect(fax.deliveries).to_not be_empty
    fax.destroy
    expect(fax.deliveries).to be_empty
  end

  describe '#title' do
    it 'returns the patient infos' do
      patient = double('patient', info: 'hey')
      fax.stub(:patient).and_return(patient)
      expect(fax.title).to eq 'hey'
    end
  end

  describe '#deliver' do
    let(:print_job) { double('print_job', print: true, job_id: 23) }
    let(:fax) { create(:fax) }

    before do
      fax.stub(:print_job).and_return(print_job)
    end

    context 'with print_job_id' do
      let(:fax) { create(:fax, print_job_id: 23) }

      it 'does not deliver again' do
        fax.deliver
        expect(print_job).to_not have_received(:print)
      end
    end

    context 'without print_job_id' do
      let(:fax) { create(:fax, print_job_id: nil) }

      it 'delivers the print job' do
        fax.deliver
        expect(print_job).to have_received(:print)
      end

      it 'saves the print_job_id' do
        expect(fax.print_job_id).to be_nil
        fax.deliver
        fax.reload
        expect(fax.print_job_id).to eq(print_job.job_id)
      end

      it 'fails on printer errors' do
        print_job.stub(:print).and_return(false)
        expect { fax.deliver }.to raise_error
      end
    end
  end

  describe '#print_job' do
    let(:print_job) { double('print_job', :title= => nil) }
    let(:fax) { create(:fax) }

    before do
      Cups::PrintJob.stub(:new).and_return(print_job)
    end

    it 'initializes a print job' do
      fax.stub(:path).and_return('chunky.pdf')
      fax.stub(:phone).and_return('42')
      fax.send(:print_job)
      expect(Cups::PrintJob).to have_received(:new).
        with('chunky.pdf', 'Fax', {'phone' => '042'})
    end

    it 'returns the instance' do
      expect(fax.send(:print_job)).to eq print_job
    end

    it 'caches the instance' do
      2.times { fax.send(:print_job) }
      expect(Cups::PrintJob).to have_received(:new).once
    end

    it 'sets the print job title' do
      fax.stub(:title).and_return('chunky bacon')
      fax.send(:print_job)
      expect(print_job).to have_received(:title=).with(fax.title)
    end
  end

  describe '#to_s' do
    it 'returns the fax title' do
      allow(fax).to receive(:title) { 'an awesome fax' }
      expect(fax.to_s).to eq(fax.title)
    end
  end
end
