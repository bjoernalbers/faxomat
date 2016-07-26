describe Directory do
  subject { build(:directory) }

  describe '.default' do
    it 'returns first record' do
      first, second = create_pair(:directory)
      expect(described_class.default).to eq first
    end
  end

  it 'has valid factory' do
    expect(subject).to be_valid
  end

  it 'is translated' do
    expect(described_class.model_name.human).to eq 'Ordner'
  end

  describe '#exports' do
    it 'has many'
    context 'when present' do
      it 'can not be deleted'
    end
  end

  describe '#description' do
    it 'must be present' do
      subject.description = nil
      expect(subject).to be_invalid
      expect(subject.errors[:description]).to be_present
      expect {
        subject.save!(validate: false)
      }.to raise_error(ActiveRecord::ActiveRecordError)
    end

    it 'is translated' do
      expect(described_class.human_attribute_name(:description)).
        to eq 'Bezeichnung'
    end
  end

  describe '#path' do
    it 'must be present' do
      subject.path = nil
      expect(subject).to be_invalid
      expect(subject.errors[:path]).to be_present
      expect {
        subject.save!(validate: false)
      }.to raise_error(ActiveRecord::ActiveRecordError)
    end

    it 'is translated' do
      expect(described_class.human_attribute_name(:path)).
        to eq 'Pfad'
    end

    it 'must be directory' do
      subject.path = Tempfile.new('chunkybacon').to_path
      expect(subject).to be_invalid
      expect(subject.errors[:path]).to be_present
    end
  end
end
