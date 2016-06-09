describe Document do
  let(:subject) { build(:document) }

  it 'has valid factory' do
    expect(subject).to be_valid
  end

  it 'is translated' do
    expect(described_class.model_name.human).to eq 'Dokument'
    {
      title:            'Titel',
      file:             'Datei',
      file_fingerprint: 'Dateiprüfsumme',
    }.each do |attr,translation|
      expect(described_class.human_attribute_name(attr)).to eq translation
    end
  end

  it { expect(subject).to belong_to(:report) }

  it { expect(subject).to have_many(:print_jobs) }

  it { expect(subject).to validate_presence_of(:title) }

  it { expect(subject).to validate_uniqueness_of(:report_id).allow_nil }

  describe '.delivered_today' do
    let(:today) { Time.zone.now.beginning_of_day + 1.second }
    let(:yesterday) { Time.zone.yesterday.end_of_day }
    let!(:document) { create(:document, created_at: yesterday) }
    let(:subject) { described_class.delivered_today }

    it 'excludes document without delivery' do
      expect(subject).not_to include(document)
    end

    it 'excludes document with yesterdays delivery' do
      create(:print_job, document: document, created_at: yesterday)
      expect(subject).not_to include(document)
    end

    it 'includes document with todays delivery' do
      create(:print_job, document: document, created_at: today)
      expect(subject).to include(document)
    end

    it 'includes distinct documents' do
      create_pair(:print_job, document: document, created_at: today)
      expect(subject.count).to eq(1)
    end

    it 'order by print job creation date' do
      other = create(:document)
      create(:print_job, document: document)
      create(:print_job, document: other)
      expect(subject.first).to eq other
    end
  end

  describe '.to_deliver' do
    let(:documents) { [ build(:document) ] }
    let(:subject) { described_class.to_deliver }

    before do
      allow(described_class).to receive_message_chain(
        :released_for_delivery,
        :without_active_or_completed_print_job
      ) { documents }
    end

    it 'returns all documents which are released for delivery and without active or completed print jobs' do
      expect(subject).to eq documents
    end
  end

  describe '.released_for_delivery' do
    let(:subject) { described_class.released_for_delivery }

    it 'includes document without report' do
      document = create(:document)
      expect(subject).to include document
    end

    it 'includes document with verified report' do
      document = create(:verified_report).document
      expect(subject).to include document
    end

    it 'excludes document with pending report' do
      document = create(:pending_report).document
      expect(subject).not_to include document
    end

    it 'excludes document with canceled report' do
      document = create(:canceled_report).document
      expect(subject).not_to include document
    end
  end

  describe '.without_active_or_completed_print_job' do
    let(:subject) do
      described_class.send(:without_active_or_completed_print_job)
    end

    let!(:document) { create(:document) }

    it 'includes document without print jobs' do
      expect(subject).to include document
    end

    it 'includes document with aborted print job' do
      create(:aborted_print_job, document: document)
      expect(subject).to include document
    end

    it 'excludes document with active print job' do
      create(:active_print_job, document: document)
      expect(subject).not_to include document
    end

    it 'excludes document with completed print job' do
      create(:completed_print_job, document: document)
      expect(subject).not_to include document
    end

    it 'excludes document with active and aborted print job' do
      create(:active_print_job, document: document)
      create(:aborted_print_job, document: document)
      expect(subject).not_to include document
    end

    it 'excludes document with completed and aborted print job' do
      create(:completed_print_job, document: document)
      create(:aborted_print_job, document: document)
      expect(subject).not_to include document
    end
  end

  describe '.with_report' do
    let(:subject) { described_class.with_report }

    it 'includes document with report' do
      document = create(:report).document
      expect(document.report).not_to be nil
      expect(subject).to include document
    end

    it 'excludes document without report' do
      document = create(:document)
      expect(document.report).to be nil
      expect(subject).not_to include document
    end
  end

  describe '.search' do
    let(:subject) { described_class }
    let!(:document) { create(:document, title: 'Chunky Bacon') }

    it 'includes results by title' do
      expect(subject.search(title: 'bacon')).to include document
    end

    it 'ignores order of mutitple search terms' do
      expect(subject.search(title: 'bacon ky')).to include document
    end

    it 'includes no result with blank title' do
      [nil, ''].each do |title|
        query = { title: title }
        expect(subject.search(query)).to be_empty
      end
    end
  end

  describe '#recipient' do
    it { expect(subject).to belong_to(:recipient) }
    it { expect(subject).to validate_presence_of(:recipient) }
  end

  describe '#fax_number' do
    it { expect(subject).to delegate_method(:fax_number).to(:recipient) }
  end

  describe '#delivered?' do
    let(:subject) { create(:document) }

    it 'is true with completed print job' do
      create(:completed_print_job, document: subject)
      expect(subject).to be_delivered
    end

    it 'is false without completed print job' do
      create(:active_print_job, document: subject)
      create(:aborted_print_job, document: subject)
      expect(subject).not_to be_delivered
    end
  end

  describe '#released_for_delivery?' do
    it 'is true without report' do
      subject = create(:document)
      expect(subject).to be_released_for_delivery
    end

    it 'is true with verified report' do
      subject = create(:verified_report).document
      expect(subject).to be_released_for_delivery
    end

    it 'is false with pending report' do
      subject = create(:pending_report).document
      expect(subject).not_to be_released_for_delivery
    end

    it 'is false with canceled report' do
      subject = create(:canceled_report).document
      expect(subject).not_to be_released_for_delivery
    end
  end

  describe '#file' do
    it { should have_attached_file(:file) }

    it { should validate_attachment_presence(:file) }

    it { should validate_attachment_content_type(:file).
      allowing('application/pdf').
      rejecting('image/jpeg', 'image/png') }
  end

  %i(path content_type fingerprint).each do |method|
    describe "##{method}" do
      it "returns #{method} from file" do
        expect(subject).to delegate_method(method).to(:file)
      end
    end
  end

  describe '#filename' do
    it 'returns filename' do
      expect(subject.filename).to eq subject.file_file_name
    end
  end

  describe '#to_deliver?' do
    let(:subject) { create(:document) }

    it 'is true without print jobs' do
      expect(subject).to be_to_deliver
    end

    it 'is true with aborted print job' do
      create(:aborted_print_job, document: subject)
      expect(subject).to be_to_deliver
    end

    it 'is false with active print job' do
      create(:active_print_job, document: subject)
      expect(subject).not_to be_to_deliver
    end

    it 'is false with completed print job' do
      create(:completed_print_job, document: subject)
      expect(subject).not_to be_to_deliver
    end
  end

  describe '#recipient_fax_number?' do
    it 'is true when recipipent has fax number' do
      expect(subject.recipient.fax_number).to be_present
      expect(subject.recipient_fax_number?).to eq true
    end

    it 'is false when recipient has no fax number' do
      subject.recipient = build(:recipient, fax_number: nil)
      expect(subject.recipient_fax_number?).to eq false
    end
  end
end
