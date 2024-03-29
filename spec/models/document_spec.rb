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

  it { expect(subject).to have_many(:prints) }

  it { expect(subject).to have_many(:deliveries) }

  it { expect(subject).to have_many(:exports) }

  describe '.deliver' do
    subject { create(:document) }
    let(:deliverer) { double(:deliverer) }
    let(:deliverer_class) { Document::Deliverer }

    before do
      allow(described_class).to receive(:find).and_return(subject)
      allow(deliverer_class).to receive(:new).and_return(deliverer)
      allow(deliverer).to receive(:deliver)
    end

    it 'delivers the document' do
      described_class.deliver(subject.id)
      expect(described_class).to have_received(:find).with(subject.id)
      expect(deliverer_class).to have_received(:new).with(subject)
      expect(deliverer).to have_received(:deliver)
    end
  end

  describe '#title' do
    context 'without report' do
      let(:subject) { build(:document, report: nil, title: nil) }

      it 'validates presence' do
        expect(subject).to be_invalid
        expect(subject.errors[:title]).to be_present
      end
    end

    context 'with report' do
      let(:report)  { create(:report) }
      let(:subject) { build(:document, report: report, title: nil) }

      it 'does not validate presence' do
        expect(subject).to be_valid
      end

      it 'assigns title from report on save' do
        subject.save
        expect(subject.title).to eq(report.title)
      end
    end
  end

  describe '.delivered_today' do
    let(:today) { Time.zone.now.beginning_of_day + 1.second }
    let(:yesterday) { Time.zone.yesterday.end_of_day }
    let!(:document) { create(:document, created_at: yesterday) }
    let(:subject) { described_class.delivered_today }

    it 'excludes document without delivery' do
      expect(subject).not_to include(document)
    end

    it 'excludes document with yesterdays delivery' do
      create(:print, document: document, created_at: yesterday)
      expect(subject).not_to include(document)
    end

    it 'includes document with todays delivery' do
      create(:print, document: document, created_at: today)
      expect(subject).to include(document)
    end

    it 'includes distinct documents' do
      create_pair(:print, document: document, created_at: today)
      expect(subject.count).to eq(1)
    end

    it 'order by print job creation date' do
      other = create(:document)
      create(:print, document: document)
      create(:print, document: other)
      expect(subject.first).to eq other
    end
  end

  describe '.to_deliver' do
    let(:documents) { [ build(:document) ] }
    let(:subject) { described_class.to_deliver }

    before do
      allow(described_class).to receive_message_chain(
        :released_for_delivery,
        :without_active_or_completed_delivery
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
      document = create(:document, report: create(:verified_report))
      expect(subject).to include document
    end

    it 'excludes document with pending report' do
      document = create(:document, report: create(:pending_report))
      expect(subject).not_to include document
    end

    it 'excludes document with canceled report' do
      document = create(:document, report: create(:canceled_report))
      expect(subject).not_to include document
    end
  end

  describe '.without_active_or_completed_delivery' do
    let(:subject) do
      described_class.send(:without_active_or_completed_delivery)
    end

    let!(:document) { create(:document) }

    it 'includes document without delivery' do
      expect(subject).to include document
    end

    it 'includes document with aborted delivery' do
      create(:aborted_delivery, document: document)
      expect(subject).to include document
    end

    it 'excludes document with active delivery' do
      create(:active_delivery, document: document)
      expect(subject).not_to include document
    end

    it 'excludes document with completed delivery' do
      create(:completed_delivery, document: document)
      expect(subject).not_to include document
    end

    it 'excludes document with active and aborted delivery' do
      create(:active_delivery, document: document)
      create(:aborted_delivery, document: document)
      expect(subject).not_to include document
    end

    it 'excludes document with completed and aborted delivery' do
      create(:completed_delivery, document: document)
      create(:aborted_delivery, document: document)
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

  describe '#send_with_hylafax?' do
    it { expect(subject).to delegate_method(:send_with_hylafax?).to(:recipient) }
  end

  describe '#delivered?' do
    let(:subject) { create(:document) }

    it 'is true with completed delivery' do
      create(:completed_delivery, document: subject)
      expect(subject).to be_delivered
    end

    it 'is false without completed delivery' do
      create(:active_delivery, document: subject)
      create(:aborted_delivery, document: subject)
      expect(subject).not_to be_delivered
    end
  end

  describe '#released_for_delivery?' do
    it 'is true without report' do
      subject = create(:document)
      expect(subject).to be_released_for_delivery
    end

    it 'is true with verified report' do
      subject = create(:document, report: create(:verified_report))
      expect(subject).to be_released_for_delivery
    end

    it 'is false with pending report' do
      subject = create(:document, report: create(:pending_report))
      expect(subject).not_to be_released_for_delivery
    end

    it 'is false with canceled report' do
      subject = create(:document, report: create(:canceled_report))
      expect(subject).not_to be_released_for_delivery
    end
  end

  describe '#file' do
    it { should have_attached_file(:file) }

    it { should validate_attachment_content_type(:file).
      allowing('application/pdf').
      rejecting('image/jpeg', 'image/png') }

    context 'with report' do
      let(:report)  { create(:report) }
      let(:subject) { build(:document, report: report) }

      it 'does not validate presence' do
        subject.file = nil
        expect(subject).to be_valid
      end

      it 'renders file on save'
    end

    context 'without report' do
      let(:subject) { build(:document, report: nil) }

      it 'validates presence' do
        subject.file = nil
        expect(subject).to be_invalid
        expect(subject.errors[:file]).to be_present
      end
    end
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

    it 'is true without delivery' do
      expect(subject).to be_to_deliver
    end

    it 'is true with aborted delivery' do
      create(:aborted_delivery, document: subject)
      expect(subject).to be_to_deliver
    end

    it 'is false with active delivery' do
      create(:active_delivery, document: subject)
      expect(subject).not_to be_to_deliver
    end

    it 'is false with completed delivery' do
      create(:completed_delivery, document: subject)
      expect(subject).not_to be_to_deliver
    end
  end

  describe '#recipient_is_evk?' do
    let(:subject) { build(:document, recipient: recipient) }

    context 'with EVK fax number prefix' do
      let(:recipient) { create(:recipient, fax_number: '02941670') }

      it 'is true' do
        expect(subject.recipient_is_evk?).to eq true
      end
    end

    context 'with different fax number prefix' do
      let(:recipient) { create(:recipient, fax_number: '02941680') }

      it 'is false' do
        expect(subject.recipient_is_evk?).to eq false
      end
    end

    context 'without fax number' do
      let(:recipient) { create(:recipient, fax_number: nil) }

      it 'is false' do
        expect(subject.recipient_is_evk?).to eq false
      end
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

  describe '#deliver' do
    before do
      allow(DeliveryJob).to receive(:perform_later)
    end

    it 'delivers itself later' do
      # NOTE: `subject.deliver` gets called on create.
      subject.save
      expect(DeliveryJob).to have_received(:perform_later).with(subject.id)
    end
  end

  describe 'with report' do
    let(:report) { create(:report) }
    let(:document) { create(:document, report: report) }

    it 'assigns file from report on save' do
      other = create(:document)
      expect(FileUtils.identical?(document.path, other.path)).to be false
    end
  end
end
