describe PaperPrinter do
  let(:subject) { build(:paper_printer) }

  it 'has valid factory' do
    expect(subject).to be_valid
    expect(subject).to be_a described_class
  end

  describe '.default_driver_class' do
    let(:subject) { described_class }

    it 'delegates to superclass' do
      expect(subject.default_driver_class).to eq subject.superclass.default_driver_class
    end
  end

  describe '#is_fax_printer?' do
    it 'returns false' do
      expect(subject.is_fax_printer?).to eq false
    end
  end
end
