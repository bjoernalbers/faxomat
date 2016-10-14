describe Print do
  let(:subject) { build(:print) }

  it 'has valid factory' do
    expect(subject).to be_valid
    expect(subject).to be_active
    expect(subject.job_number).not_to be_present
  end

  it 'has factory for active print' do
    subject = build(:active_print)
    expect(subject).to be_valid
    expect(subject).to be_active
    expect(subject.job_number).to be_present
  end

  it 'has factory for completed print' do
    subject = build(:completed_print)
    expect(subject).to be_valid
    expect(subject).to be_completed
    expect(subject.job_number).to be_present
  end

  it 'has factory for aborted print' do
    subject = build(:aborted_print)
    expect(subject).to be_valid
    expect(subject).to be_aborted
    expect(subject.job_number).to be_present
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
      create_list(:active_print, 2, printer: printer)
      subject.update_active
      expect(driver_class).to have_received(:statuses).with(printer.name).once
    end

    it 'updates active print jobs' do
      print = create(:active_print, printer: printer)
      allow(driver_class).to receive(:statuses).
        and_return({print.job_number => :completed})
      subject.update_active
      print.reload
      expect(print).to be_completed
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

  describe '#printer' do
    it { expect(subject).to belong_to(:printer) }
    it { expect(subject).to validate_presence_of(:printer) }

    it 'returns even deleted printers' do
      printer = create(:printer)
      subject = create(:print, printer: printer)
      expect { printer.destroy }.not_to change { subject.reload.printer }
    end
  end

  describe '#fax_number' do
    context 'with fax printer' do
      let(:subject) { build(:print, printer: create(:fax_printer)) }

      it 'validates presence' do
        # NOTE: This little hack is required to avoid that the print job copies
        # the fax number from recipient before validation.
        recipient_without_fax_number = create(:recipient, fax_number: nil)
        document = create(:document, recipient: recipient_without_fax_number)
        subject = build(:print, document: document)
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
      let(:subject) { build(:print, printer: create(:paper_printer)) }
      
      it { expect(subject).not_to validate_presence_of(:fax_number) }
    end
  end

  describe '#job_number' do
    before do
      allow(subject).to receive(:print)
    end

    it 'is translated' do
      translation = subject.class.human_attribute_name(:job_number)
      expect(translation).to eq 'Auftragsnummer'
    end

    it 'does not validates presence' do
      expect(subject).not_to validate_presence_of(:job_number)
    end

    it 'validates presence in database' do
      expect{ subject.save!(validate: false) }.
        to raise_error(ActiveRecord::ActiveRecordError)
    end

    it 'does not validate uniqueness' do
      expect(subject).not_to validate_uniqueness_of(:job_number)
    end

    it 'validates uniqueness in database' do
      subject.job_number = create(:completed_print).job_number
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
        allow(driver).to receive(:run).and_return(true)
        allow(driver).to receive(:job_number).and_return(42)
      end

      it 'assigns job_number' do
        subject.save
        expect(subject.job_number).to eq 42
      end

      it 'is active' do
        subject.save
        expect(subject).to be_active
      end

      it 'calls driver' do
        subject.save
        expect(driver).to have_received(:run)
      end
    end

    context 'when not printable' do
      before do
        allow(driver).to receive(:run).and_return(false)
      end
      
      it 'can not be saved' do
        expect(subject.save).to eq false
      end

      it 'does not assign job_number' do
        subject.save
        expect(subject.job_number).to be nil
      end

      it 'is active' do
        subject.save
        expect(subject).to be_active
      end

      it 'calls driver' do
        subject.save
        expect(driver).to have_received(:run)
      end
    end

    context 'with existing job_number' do
      before do
        subject.job_number = 42
        allow(driver).to receive(:run)
      end

      it 'does not call driver' do
        subject.save
        expect(driver).not_to have_received(:run)
      end
    end
  end

  describe '.count_by_status' do
    before { pending }
    it 'returns number of prints by status' do
      2.times { create(:active_print) }
      1.times { create(:aborted_print) }
      0.times { create(:completed_print) }

      expect(described_class.count_by_status[:active]).to eq 2
      expect(described_class.count_by_status[:aborted]).to eq 1
      expect(described_class.count_by_status[:completed]).to eq 0
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

    it 'returns today updated prints' do
      subject = create(:print, updated_at: now.beginning_of_day)
      expect(described_class.updated_today).to include(subject)
    end

    it 'does not return prints updated before today' do
      subject = create(:print, updated_at: now.beginning_of_day-1.second)
      expect(described_class.updated_today).to_not include(subject)
    end
  end

  describe '.search' do
    before { skip }
    let(:document) { create(:document, title: 'Chunky Bacon') }
    let!(:subject) { create(:print, document: document) }
    let!(:other_print) { create(:print) }

    it 'searches by matching title' do
      query = {title: 'Chunky Bacon'}
      expect(described_class.search(query)).to match_array [subject]
    end

    it 'searches by title fragment' do
      query = {title: 'unk'}
      expect(described_class.search(query)).to match_array [subject]
    end

    it 'searches for all query words' do
      skip
      query = {title: 'Bacon Chunky'}
      expect(described_class.search(query)).to match_array [subject]
    end

    it 'handles german umlauts' do
      document = create(:document, title: 'Björn')
      subject = create(:print, document: document)
      query = {title: 'Björn'}
      expect(described_class.search(query)).to match_array [subject]
    end

    it 'searches by fax number' do
      subject = create(:print, fax_number: '042424242')
      query = {fax_number: subject.fax_number}
      expect(described_class.search(query)).to match_array [subject]
    end

    it 'does not search with blank query' do
      [nil, ''].each do |query|
        expect(described_class.search(title: query)).to be_empty
      end
    end
  end

  describe '#driver' do
    let(:driver) { double(:driver) }
    let(:driver_class) { double('driver_class') }

    before do
      allow(driver).to receive(:run)
      allow(driver_class).to receive(:new).and_return(driver)
      allow(described_class).to receive(:driver_class).
        and_return(driver_class)
    end

    it 'initializes driver' do
      subject.send(:driver)
      expect(driver_class).to have_received(:new).with(subject)
    end

    it 'returns cached driver' do
      allow(driver_class).to receive(:new).and_return(driver)
      2.times { expect(subject.send(:driver)).to eq driver }
      expect(driver_class).to have_received(:new).twice # wg. callback "twice", sonst "once"
    end
  end
end
