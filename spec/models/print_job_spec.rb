describe PrintJob do
  let(:subject) { build(:print_job) }

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

  describe '#report' do
    it { expect(subject).to belong_to(:report) }
  end

  describe '#document' do
    it { expect(subject).to belong_to(:document) }
    it { expect(subject).to validate_presence_of(:document) }
  end

  describe '#printer' do
    it { expect(subject).to belong_to(:printer) }
    it { expect(subject).to validate_presence_of(:printer) }
  end

  describe '#fax_number' do
    context 'with fax printer' do
      let(:subject) { build(:print_job, printer: create(:fax_printer)) }

      it { expect(subject).to validate_presence_of(:fax_number) }

      it 'validates minimum length' do
        subject.fax_number = '0123456'
        expect(subject).to be_invalid
        expect(subject.errors[:fax_number]).to be_present
        subject.fax_number = '01234567'
        expect(subject).to be_valid
      end

      it 'validates excactly one leading zero' do
        %w(123456789  00123456789).each do |fax_number|
          subject.fax_number = fax_number
          expect(subject).to be_invalid
          expect(subject.errors[:fax_number]).to be_present
          expect(subject.errors[:fax_number]).to include('ist keine gültige nationale Faxnummer mit Vorwahl')
        end
      end
      
      it 'strips non-digits on validation' do
        subject.fax_number = ' 0123-456 789 '
        subject.validate
        expect(subject.fax_number).to eq '0123456789'

        subject.fax_number = ' '
        subject.validate
        expect(subject.fax_number).to be nil
      end
    end

    context 'with paper printer' do
      let(:subject) { build(:print_job, printer: create(:paper_printer)) }
      
      it { expect(subject).not_to validate_presence_of(:fax_number) }
    end
  end

  describe '#cups_job_id' do
    context 'without status' do
      let(:subject) { build(:print_job, status: nil) }

      it { expect(subject).to validate_absence_of(:cups_job_id) }

      context 'and when nil but non-unique' do
        before do
          create(:print_job, status: nil, cups_job_id: nil)
          subject.cups_job_id = nil
        end

        it 'is valid' do
          expect(subject).to be_valid
        end

        it 'can be saved' do
          expect{ subject.save!(validate: false) }.not_to raise_error
        end
      end
    end

    context 'with status' do
      let(:subject) { build(:print_job, status: :active) }

      it { expect(subject).to validate_presence_of(:cups_job_id) }

      it { expect(subject).to validate_uniqueness_of(:cups_job_id) }
    end
  end

  context 'when saved without cups_job_id and status' do
    let(:subject) { build(:print_job, cups_job_id: nil, status: nil) }

    before do
      allow(subject).to receive(:print)
      subject.save!
    end

    it 'prints itself' do
      expect(subject).to have_received(:print)
    end
  end

  context 'when saved with cups_job_id and status' do
    let(:subject) { build(:completed_print_job) }

    before do
      allow(subject).to receive(:print)
      subject.save!
    end

    it 'does not print itself' do
      expect(subject).not_to have_received(:print)
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

  %i(path title content_type).each do |attr|
    describe "##{attr}" do
      it "returns document #{attr}" do
        expect(subject).to delegate_method(attr).to(:document)
      end
    end
  end

  describe '#to_s' do
    it 'returns title' do
      expect(subject.to_s).to eq subject.title
    end
  end

  describe '.updated_today' do
    let(:now) { DateTime.current }

    it 'returns today updated print_jobs' do
      subject = create(:print_job, updated_at: now.beginning_of_day)
      expect(PrintJob.updated_today).to include(subject)
    end

    it 'does not return print_jobs updated before today' do
      subject = create(:print_job, updated_at: now.beginning_of_day-1.second)
      expect(PrintJob.updated_today).to_not include(subject)
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
      subject = create(:print_job, created_at: monday_morning_last_week)
      expect(PrintJob.created_last_week).to include subject
    end

    it 'includes print_job from sunday night last week' do
      subject = create(:print_job, created_at: sunday_night_last_week)
      expect(PrintJob.created_last_week).to include subject
    end

    it 'excludes print_job before monday morning last week' do
      subject = create(:print_job, created_at: monday_morning_last_week - 1.second)
      expect(PrintJob.created_last_week).not_to include subject
    end

    it 'excludes print_job after sunday night last week' do
      subject = create(:print_job, created_at: sunday_night_last_week + 1.second)
      expect(PrintJob.created_last_week).not_to include subject
    end
  end

  describe '.search' do
    let(:document) { create(:document, title: 'Chunky Bacon') }
    let!(:subject) { create(:print_job, document: document) }
    let!(:other_print_job) { create(:print_job) }

    it 'searches by matching title' do
      query = {title: 'Chunky Bacon'}
      expect(PrintJob.search(query)).to match_array [subject]
    end

    it 'searches case-insensitive' do
      query = {title: 'chunky bacon'}
      expect(PrintJob.search(query)).to match_array [subject]
    end

    it 'searches by title fragment' do
      query = {title: 'unk'}
      expect(PrintJob.search(query)).to match_array [subject]
    end

    it 'searches for all query words' do
      skip
      query = {title: 'Bacon Chunky'}
      expect(PrintJob.search(query)).to match_array [subject]
    end

    it 'handles german umlauts' do
      document = create(:document, title: 'Björn')
      subject = create(:print_job, document: document)
      query = {title: 'Björn'}
      expect(PrintJob.search(query)).to match_array [subject]
    end

    it 'searches by fax number' do
      subject = create(:print_job, fax_number: '042424242')
      query = {fax_number: subject.fax_number}
      expect(PrintJob.search(query)).to match_array [subject]
    end

    it 'does not search with blank query' do
      [nil, ''].each do |query|
        expect(PrintJob.search(title: query)).to be_empty
      end
    end
  end

  describe '#destroy' do
    let(:message) { 'Nur abgebrochene Druckaufträge können gelöscht werden.' }

    it 'destroys aborted print_job' do
      subject = create(:aborted_print_job)
      subject.destroy
      expect(subject).to be_destroyed
    end

    it 'does not destroy completed print_job' do
      subject = create(:completed_print_job)
      subject.destroy
      expect(subject).not_to be_destroyed
      expect(subject.errors[:base]).to include(message)
    end
    
    it 'does not destroy active print_job' do
      subject = create(:active_print_job)
      subject.destroy
      expect(subject).not_to be_destroyed
      expect(subject.errors[:base]).to include(message)
    end

    it 'does not destroy unsend print_job' do
      subject = create(:print_job)
      subject.destroy
      expect(subject).not_to be_destroyed
      expect(subject.errors[:base]).to include(message)
    end
  end
end
