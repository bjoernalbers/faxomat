describe PaperPrinter do
  let(:subject) { build(:paper_printer) }

  it 'has valid factory' do
    expect(subject).to be_valid
    expect(subject).to be_a described_class
  end

  describe '.default' do
    let(:subject) { described_class.default }

    it 'returns first paper printer' do
      first, second = create_pair(:paper_printer)
      expect(subject).to eq described_class.first
    end
  end

  describe '#is_fax_printer?' do
    it 'returns false' do
      expect(subject.is_fax_printer?).to eq false
    end
  end
end
