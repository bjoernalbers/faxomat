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

  it { expect(print_job).to belong_to(:printer) }

  it { expect(print_job).to belong_to(:report) }

  describe '#fax_number' do
    context 'with fax printer' do
      let(:print_job) { build(:print_job, printer: create(:fax_printer)) }

      it { expect(print_job).to validate_presence_of(:fax_number) }

      it 'validates minimum length' do
        print_job.fax_number = '0123456'
        expect(print_job).to be_invalid
        expect(print_job.errors[:fax_number]).to be_present
        print_job.fax_number = '01234567'
        expect(print_job).to be_valid
      end

      it 'validates excactly one leading zero' do
        %w(123456789  00123456789).each do |fax_number|
          print_job.fax_number = fax_number
          expect(print_job).to be_invalid
          expect(print_job.errors[:fax_number]).to be_present
          expect(print_job.errors[:fax_number]).to include('ist keine gültige nationale Faxnummer mit Vorwahl')
        end
      end
      
      it 'strips non-digits on validation' do
        print_job.fax_number = ' 0123-456 789 '
        print_job.validate
        expect(print_job.fax_number).to eq '0123456789'

        print_job.fax_number = ' '
        print_job.validate
        expect(print_job.fax_number).to be nil
      end
    end

    context 'with paper printer' do
      let(:print_job) { build(:print_job, printer: create(:paper_printer)) }
      
      it { expect(print_job).not_to validate_presence_of(:fax_number) }
    end
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

    before do
      allow(print_job).to receive(:print)
      print_job.save!
    end

    it 'prints itself' do
      expect(print_job).to have_received(:print)
    end
  end

  context 'when saved with cups_job_id and status' do
    let(:print_job) { build(:completed_print_job) }

    before do
      allow(print_job).to receive(:print)
      print_job.save!
    end

    it 'does not print itself' do
      expect(print_job).not_to have_received(:print)
    end
  end

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

  it 'validates the presence of a document' do
    print_job = build(:print_job, document: nil)
    expect(print_job).to_not be_valid
    expect(print_job.errors[:document].size).to eq(1)
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

    it 'searches by fax number' do
      print_job = create(:print_job, fax_number: '042424242')
      query = {fax_number: print_job.fax_number}
      expect(PrintJob.search(query)).to match_array [print_job]
    end

    it 'does not search with blank query' do
      [nil, ''].each do |query|
        expect(PrintJob.search(title: query)).to be_empty
      end
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

  describe '#document_fingerprint' do
    let(:path) { Rails.root.join('spec', 'support', 'sample.pdf') }

    before do
      File.open(path) do |file|
        print_job.document = file
        print_job.save
      end
    end

    it 'gets assigned when created' do
      expect(print_job.document_fingerprint).to be_present
      expect(print_job.document_fingerprint).
        to eq Digest::MD5.file(print_job.document.path).to_s
    end

    it 'is equal to PrintJob#document.fingerprint' do
      expect(print_job.document_fingerprint).
        to eq print_job.document.fingerprint
    end
  end
end
