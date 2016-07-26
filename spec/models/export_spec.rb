describe Export do
  subject { build(:export) }

  it 'has valid factory' do
    expect(subject).to be_valid
  end

  it 'is translated' do
    expect(described_class.model_name.human).to eq 'Export'
  end

  it_behaves_like 'a deliverable'

  describe '#directory' do
    it 'must be present' do
      subject.directory = nil
      expect(subject).to be_invalid
      expect(subject.errors[:directory]).to be_present
      expect {
        subject.save!(validate: false)
      }.to raise_error(ActiveRecord::ActiveRecordError)
    end

    it 'is translated' do
      expect(described_class.human_attribute_name(:directory)).
        to eq 'Ordner'
    end
  end

  describe '#filename' do
    it 'must be present' do
      subject.filename = nil
      expect(subject).to be_invalid
      expect(subject.errors[:filename]).to be_present
      expect {
        subject.save!(validate: false)
      }.to raise_error(ActiveRecord::ActiveRecordError)
    end

    it 'is translated' do
      expect(described_class.human_attribute_name(:filename)).
        to eq 'Dateiname'
    end
  end
end
