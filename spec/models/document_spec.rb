describe Document do
  let(:subject) { build(:document) }

  it 'has valid factory' do
    expect(subject).to be_valid
  end

  it { expect(subject).to belong_to(:report) }

  it { expect(subject).to have_many(:print_jobs) }

  it { expect(subject).to validate_presence_of(:title) }

  it { expect(subject).to validate_uniqueness_of(:report_id).allow_nil }

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
end
