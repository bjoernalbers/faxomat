describe PrintJob do
  let(:print_job) { build(:print_job) }

  it 'has a factory with attached document' do
    expect(print_job.document.path).to_not be_nil
  end

  it 'has factory for active print_job' do
    expect(build(:active_print_job)).to be_active
    expect(build(:print_job)).to be_active
  end

  it 'has factory for completed print_job' do
    expect(build(:completed_print_job)).to be_completed
  end

  it 'has factory for aborted print_job' do
    expect(build(:aborted_print_job)).to be_aborted
  end

  describe '#cups_job_id' do
    context 'without status' do
      let(:print_job) { build(:print_job, status: nil) }

      it { expect(print_job).to validate_absence_of(:cups_job_id) }

      context 'and when nil but non-unique' do
        before do
          create(:print_job, status: nil, cups_job_id: nil)
          print_job.cups_job_id = nil
        end

        it 'is valid' do
          expect(print_job).to be_valid
        end

        it 'can be saved' do
          expect{ print_job.save!(validate: false) }.not_to raise_error
        end
      end
    end

    context 'with status' do
      let(:print_job) { build(:print_job, status: :active) }

      it { expect(print_job).to validate_presence_of(:cups_job_id) }

      it { expect(print_job).to validate_uniqueness_of(:cups_job_id) }
    end
  end

  context 'when saved without cups_job_id and status' do
    let(:print_job) { build(:print_job, cups_job_id: nil, status: nil) }
    let(:printer) { double('printer') }

    before do
      allow(print_job).to receive(:printer).and_return(printer)
      allow(printer).to receive(:print)
    end

    it 'prints itself' do
      print_job.save!
      expect(printer).to have_received(:print).with(print_job)
    end
  end

  context 'when saved with cups_job_id and status' do
    let(:print_job) { build(:completed_print_job) }
    let(:printer) { double('printer') }

    before do
      allow(print_job).to receive(:printer).and_return(printer)
      allow(printer).to receive(:print)
    end

    it 'does not print itself' do
      print_job.save!
      expect(printer).not_to have_received(:print)
    end
  end

  context 'when valid and saved' do
    let(:printer) { double(:printer) }
    let(:cups_job_id_from_printer) { 98716 }
    let(:print_job) { build(:print_job) }

    before do
      skip 'FIX printing / faxing!'

      allow(printer).to receive(:print).and_return(cups_job_id_from_printer)
      allow(print_job).to receive(:printer).and_return(printer)
    end

    context 'with cups_job_id' do
      let(:print_job) { build(:print_job, cups_job_id: 458731, status: :completed) }

      before do
        print_job.save!
      end

      it 'does not get printed' do
        expect(printer).not_to have_received(:print)
      end

      it 'is persisted' do
        expect(print_job).to be_persisted
      end

      it 'stores assigned cups_job_id' do
        expect(print_job.cups_job_id).to eq 458731
      end

      it 'does not overwrite status as active' do
        expect(print_job).to be_completed
      end
    end

    context 'without cups_job_id' do
      let(:print_job) { build(:print_job, cups_job_id: nil, status: :completed) }

      before do
        print_job.save!
      end

      it 'gets printed' do
        expect(printer).to have_received(:print).with(print_job)
      end

      it 'stores cups_job_id from printer' do
        expect(print_job.cups_job_id).to eq cups_job_id_from_printer
      end

      it 'overwrites status as active' do
        expect(print_job).to be_active
      end

      it 'is persisted' do
        expect(print_job).to be_persisted
      end
    end

    context 'without cups_job_id but failed print' do
      let(:print_job) { build(:print_job, cups_job_id: nil, status: :completed) }

      before do
        allow(printer).to receive(:print).and_return(nil)
        print_job.save
      end

      it 'is not persisted' do
        expect(print_job).not_to be_persisted
      end

      it 'is not active' do
        expect(print_job).not_to be_active
      end

      it 'contains an error' do
        expect(print_job.errors[:base]).to be_present
      end
    end
  end

  it { expect(print_job).to belong_to(:report) }

  describe '.count_by_status' do
    it 'returns number of print_jobs by status' do
      2.times { create(:active_print_job) }
      1.times { create(:aborted_print_job) }
      0.times { create(:completed_print_job) }

      expect(PrintJob.count_by_status[:active]).to eq 2
      expect(PrintJob.count_by_status[:aborted]).to eq 1
      expect(PrintJob.count_by_status[:completed]).to eq 0
    end
  end

  it 'does not store documents under a public available location' do
    File.open(Rails.root.join('spec', 'support', 'sample.pdf')) do |doc|
      print_job.document = doc
      print_job.save!
    end
    expect(print_job.document.path).to_not match /public/i
  end

  describe '#path' do
    it 'returns the document path' do
      expect(print_job.path).to eq(print_job.document.path)
    end
  end

  context 'without fax_number' do
    let(:phone) { '01230123' }
    let(:print_job) { build(:print_job, fax_number: nil, phone: phone) }

    it 'creates and assigns a new fax_number by phone' do
      expect{print_job.save}.to change(FaxNumber, :count).by 1
      expect(print_job.fax_number).to eq FaxNumber.find_by(phone: phone)
    end

    it 'finds and assigns an existing fax_number by phone' do
      create(:fax_number, phone: phone)
      expect{print_job.save}.to change(FaxNumber, :count).by 0
      expect(print_job.fax_number).to eq FaxNumber.find_by(phone: phone)
    end
  end

  it 'validates the presence of phone' do
    print_job = build(:print_job, fax_number: nil, phone: nil)
    expect(print_job).to be_invalid
    expect(print_job.errors[:phone]).to_not be_empty
  end

  it 'validates the presence of a document' do
    print_job = build(:print_job, document: nil)
    expect(print_job).to_not be_valid
    expect(print_job.errors[:document].size).to eq(1)
  end

  it 'cleans the phone number from non-digits before save' do
    print_job = create(:print_job, phone: ' 0123-456 789 ')
    expect(print_job.phone).to eq '0123456789'
  end

  it 'is invalid with too short phone' do
    print_job = build(:print_job, phone: '0123456')
    print_job.valid?
    expect(print_job.errors[:phone].size).to eq 1
  end

  it 'is invalid when phone has no leading zero' do
    print_job = build(:print_job, phone: '123456789')
    print_job.valid?
    expect(print_job.errors[:phone].size).to eq 1
    expect(print_job.errors[:phone]).to include('has no area code')
  end

  it 'is invalid when phone has more then one leading zero' do
    print_job = build(:print_job, phone: '00123456789')
    print_job.valid?
    expect(print_job.errors[:phone].size).to eq 1
    expect(print_job.errors[:phone]).to include('has no area code')
  end

  context 'without a fax_number' do
    let(:print_job) { build(:print_job, fax_number: nil) }

    it 'can not be saved in the database' do
      expect { print_job.save!(validate: false) }.to raise_error
    end
  end

  describe '.updated_today' do
    let(:now) { DateTime.current }

    it 'returns today updated print_jobs' do
      print_job = create(:print_job, updated_at: now.beginning_of_day)
      expect(PrintJob.updated_today).to include(print_job)
    end

    it 'does not return print_jobs updated before today' do
      print_job = create(:print_job, updated_at: now.beginning_of_day-1.second)
      expect(PrintJob.updated_today).to_not include(print_job)
    end
  end

  describe '.created_last_week' do
    let(:now) { Time.zone.local(2015, 1, 13, 20, 59, 59) }
    let(:monday_morning_last_week) { Time.zone.local(2015, 1, 5, 0, 0, 0) }
    let(:sunday_night_last_week) { Time.zone.local(2015, 1, 11, 23, 59, 59) }

    before do
      Timecop.freeze(now)
    end

    after do
      Timecop.return
    end

    it 'includes print_job from monday morning last week' do
      print_job = create(:print_job, created_at: monday_morning_last_week)
      expect(PrintJob.created_last_week).to include print_job
    end

    it 'includes print_job from sunday night last week' do
      print_job = create(:print_job, created_at: sunday_night_last_week)
      expect(PrintJob.created_last_week).to include print_job
    end

    it 'excludes print_job before monday morning last week' do
      print_job = create(:print_job, created_at: monday_morning_last_week - 1.second)
      expect(PrintJob.created_last_week).not_to include print_job
    end

    it 'excludes print_job after sunday night last week' do
      print_job = create(:print_job, created_at: sunday_night_last_week + 1.second)
      expect(PrintJob.created_last_week).not_to include print_job
    end
  end

  describe '.check' do
    it 'updates active print jobs' do
      printer = double('printer')
      allow(printer).to receive(:check)
      allow(Printer).to receive(:new).and_return(printer)
      allow(PrintJob).to receive(:active).and_return( [print_job] )
      PrintJob.check
      expect(printer).to have_received(:check).with( [print_job] )
    end
  end

  describe '.search' do
    let!(:other_print_job) { create(:print_job, title: 'another print_job') }
    let!(:print_job) { create(:print_job, title: 'Chunky Bacon') }

    it 'searches by matching title' do
      query = {title: 'Chunky Bacon'}
      expect(PrintJob.search(query)).to match_array [print_job]
    end

    it 'searches case-insensitive' do
      query = {title: 'chunky bacon'}
      expect(PrintJob.search(query)).to match_array [print_job]
    end

    it 'searches by title fragment' do
      query = {title: 'unk'}
      expect(PrintJob.search(query)).to match_array [print_job]
    end

    it 'searches for all query words' do
      skip
      query = {title: 'Bacon Chunky'}
      expect(PrintJob.search(query)).to match_array [print_job]
    end

    it 'handles german umlauts' do
      print_job = create(:print_job, title: 'Björn')
      query = {title: 'Björn'}
      expect(PrintJob.search(query)).to match_array [print_job]
    end

    it 'searches for the document name'

    it 'searches by phone' do
      print_job = create(:print_job, phone: '042424242')
      query = {phone: print_job.phone}
      expect(PrintJob.search(query)).to match_array [print_job]
    end

    it 'does not search with blank query' do
      [nil, ''].each do |query|
        expect(PrintJob.search(title: query)).to be_empty
      end
    end
  end

  describe '#phone' do
    let(:phone) { '01234754' }

    it 'returns @phone when set' do
      print_job = build(:print_job, phone: phone, fax_number: nil)
      expect(print_job.phone).to eq phone
    end

    it 'returns fax_number.phone when @phone is not set' do
      fax_number = build(:fax_number, phone: '09823121')
      print_job = build(:print_job, phone: nil, fax_number: fax_number)
      expect(print_job.phone).to eq fax_number.phone
    end

    it 'returns nil when @phone and fax_number are not set' do
      print_job = build(:print_job, phone: nil, fax_number: nil)
      expect(print_job.phone).to be_nil
    end
  end

  context 'without title' do
    let(:print_job) { build(:print_job, title: nil) }

    it 'is not valid' do
      expect(print_job).not_to be_valid
      expect(print_job.errors[:title]).not_to be_empty
    end

    it 'is not storable' do
      expect{ print_job.save!(validate: false) }.to raise_error
    end
  end

  describe '#document' do
    it 'allows to attach documents' do
      filename = File.join(File.dirname(__FILE__), '..', 'support', 'sample.pdf')
      file = File.open(filename)
        print_job.document = file
        print_job.save!
      file.close
    end
  end

  describe '#to_s' do
    it 'returns the print_job title' do
      allow(print_job).to receive(:title) { 'an awesome print_job' }
      expect(print_job.to_s).to eq(print_job.title)
    end
  end

  describe '#status' do
    #TODO: Test!
  end

  describe '#destroy' do
    let(:message) { 'Nur abgebrochene Druckaufträge können gelöscht werden.' }

    it 'destroys aborted print_job' do
      print_job = create(:aborted_print_job)
      print_job.destroy
      expect(print_job).to be_destroyed
    end

    it 'does not destroy completed print_job' do
      print_job = create(:completed_print_job)
      print_job.destroy
      expect(print_job).not_to be_destroyed
      expect(print_job.errors[:base]).to include(message)
    end
    
    it 'does not destroy active print_job' do
      print_job = create(:active_print_job)
      print_job.destroy
      expect(print_job).not_to be_destroyed
      expect(print_job.errors[:base]).to include(message)
    end

    it 'does not destroy unsend print_job' do
      print_job = create(:print_job)
      print_job.destroy
      expect(print_job).not_to be_destroyed
      expect(print_job.errors[:base]).to include(message)
    end
  end
end
