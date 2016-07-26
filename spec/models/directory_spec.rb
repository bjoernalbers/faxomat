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
    it { should have_many(:exports) }

    context 'when present' do
      before do
        create(:export, directory: subject)
      end

      it 'raises error on delete' do
        expect {
          subject.delete
        }.to raise_error(ActiveRecord::ActiveRecordError)
      end

      it 'returns false on destroy' do
        expect(subject.destroy).to eq false
        expect(subject).to be_persisted
      end
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

    it 'returns Pathname instance' do
      subject = build(:directory, path: nil)
      expect(subject.path).to be nil
      subject = build(:directory)
      expect(subject.path).to be_a(Pathname)
    end
  end
end
