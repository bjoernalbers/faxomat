describe PaperPrinter do
  let(:subject) { build(:paper_printer) }

  it 'has valid factory' do
    expect(subject).to be_valid
    expect(subject).to be_a described_class
  end

  describe '#is_fax_printer?' do
    it 'returns false' do
      expect(subject.is_fax_printer?).to eq false
    end
  end
end
