describe PrintJob do
  let(:subject) { build(:print_job) }

  it 'has valid factory' do
    expect(subject).to be_valid
    expect(subject).to be_active
    expect(subject.job_id).not_to be_present
  end

  it 'has factory for active print_job' do
    subject = build(:active_print_job)
    expect(subject).to be_valid
    expect(subject).to be_active
    expect(subject.job_id).to be_present
  end

  it 'has factory for completed print_job' do
    subject = build(:completed_print_job)
    expect(subject).to be_valid
    expect(subject).to be_completed
    expect(subject.job_id).to be_present
  end

  it 'has factory for aborted print_job' do
    subject = build(:aborted_print_job)
    expect(subject).to be_valid
    expect(subject).to be_aborted
    expect(subject.job_id).to be_present
  end

  describe '.update_active' do
    let(:subject) { described_class }
    let(:driver_class) { double('driver class') }
    let(:printer) { create(:printer) }

    before do
      allow(driver_class).to receive(:statuses).and_return({})
      allow(subject).to receive(:driver_class).and_return(driver_class)
    end

    it 'groups status queries by printer' do
      create_list(:active_print_job, 2, printer: printer)
      subject.update_active
      expect(driver_class).to have_received(:statuses).with(printer.name).once
    end

    it 'updates active print jobs' do
      print_job = create(:active_print_job, printer: printer)
      allow(driver_class).to receive(:statuses).
        and_return({print_job.job_id => :completed})
      subject.update_active
      print_job.reload
      expect(print_job).to be_completed
    end
  end

  describe '.active_or_completed' do
    let(:subject) { described_class.active_or_completed }

    it 'includes active print job' do
      print_job = create(:active_print_job)
      expect(subject).to include print_job
    end

    it 'includes completed print job' do
      print_job = create(:completed_print_job)
      expect(subject).to include print_job
    end

    it 'excludes aborted print job' do
      print_job = create(:aborted_print_job)
      expect(subject).not_to include print_job
    end
  end

  describe '.driver_class' do
    let(:subject) { described_class }

    it 'is test driver in current environment' do
      expect(subject.driver_class).to eq described_class::TestDriver
    end

    context 'with fake_printing enabled' do
      before do
        allow(subject).to receive(:fake_printing?).and_return(true)
      end

      it 'returns test driver' do
        expect(subject.driver_class).to eq described_class::TestDriver
      end
    end

    context 'with fake_printing disabled' do
      before do
        allow(subject).to receive(:fake_printing?).and_return(false)
      end

      it 'returns CUPS driver' do
        expect(subject.driver_class).to eq described_class::CupsDriver
      end
    end
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

      it 'validates presence' do
        # NOTE: This little hack is required to avoid that the print job copies
        # the fax number from recipient before validation.
        recipient_without_fax_number = create(:recipient, fax_number: nil)
        document = create(:document, recipient: recipient_without_fax_number)
        subject = build(:print_job, document: document)
        subject.fax_number = nil

        expect(subject.fax_number).to be nil
        expect(subject).to be_invalid
        expect(subject.errors[:fax_number]).to be_present
      end

      it 'gets assigned from document on create' do
        subject.fax_number = nil
        subject.save!
        expect(subject.fax_number).to be_present
        expect(subject.fax_number).to eq subject.document.fax_number
      end

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

  describe '#job_id' do
    before do
      allow(subject).to receive(:print)
    end

    it 'is translated' do
      translation = subject.class.human_attribute_name(:job_id)
      expect(translation).to eq 'Auftragsnummer'
    end

    it 'does not validates presence' do
      expect(subject).not_to validate_presence_of(:job_id)
    end

    it 'validates presence in database' do
      expect{ subject.save!(validate: false) }.
        to raise_error(ActiveRecord::ActiveRecordError)
    end

    it 'does not validate uniqueness' do
      expect(subject).not_to validate_uniqueness_of(:job_id)
    end

    it 'validates uniqueness in database' do
      subject.job_id = create(:completed_print_job).job_id
      expect{ subject.save!(validate: false) }.
        to raise_error(ActiveRecord::ActiveRecordError)
    end
  end

  describe '#status' do
    it 'is active by default' do
      expect(subject).to be_active
    end

    it 'validates presence in database' do
      subject.status = nil
      expect{ subject.save!(validate: false) }.
        to raise_error(ActiveRecord::ActiveRecordError)
    end
  end

  describe 'on create' do
    let(:driver) { double('driver') }

    before do
      allow(subject).to receive(:driver).and_return(driver)
    end

    context 'when printable' do
      before do
        allow(driver).to receive(:print).and_return(true)
        allow(driver).to receive(:job_id).and_return(42)
      end

      it 'assigns job_id' do
        subject.save
        expect(subject.job_id).to eq 42
      end

      it 'is active' do
        subject.save
        expect(subject).to be_active
      end
    end

    context 'when not printable' do
      before do
        allow(driver).to receive(:print).and_return(false)
      end
      
      it 'can not be saved' do
        expect(subject.save).to eq false
      end

      it 'does not assign job_id' do
        subject.save
        expect(subject.job_id).to be nil
      end

      it 'is active' do
        subject.save
        expect(subject).to be_active
      end
    end

    context 'with existing job_id' do
      before do
        subject.job_id = 42
        allow(driver).to receive(:print)
      end

      it 'does not print job' do
        subject.save
        expect(driver).not_to have_received(:print)
      end
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

  describe '#driver' do
    let(:driver_class) { double('driver_class') }

    before do
      allow(driver_class).to receive(:new)
      allow(described_class).to receive(:driver_class).
        and_return(driver_class)
    end

    it 'initializes driver' do
      subject.send(:driver)
      expect(driver_class).to have_received(:new).with(subject)
    end

    it 'returns cached driver' do
      allow(driver_class).to receive(:new).and_return(:a_driver)
      2.times { expect(subject.send(:driver)).to eq :a_driver }
      expect(driver_class).to have_received(:new).once
    end
  end
end
