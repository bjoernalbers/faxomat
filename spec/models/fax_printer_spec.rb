describe FaxPrinter do
  let(:subject) { build(:fax_printer) }

  it 'has valid factory' do
    expect(subject).to be_valid
    expect(subject).to be_a described_class
    expect(subject.dialout_prefix).to be_present
  end

  describe '.default' do
    let(:subject) { described_class.default }

    it 'returns first fax printer' do
      first, second = create_pair(:fax_printer)
      expect(subject).to eq described_class.first
    end

    it 'is not present without seeded database' do
      expect(subject).not_to be_present
    end

    it 'is present with seeded database' do
      Rails.application.load_seed
      expect(subject).to be_present
      expect(subject.name).to eq 'Fax'
      expect(subject.label).to eq 'Faxgerät'
      expect(subject.dialout_prefix).to be nil
    end
  end

  describe '#is_fax_printer?' do
    it 'returns true' do
      expect(subject.is_fax_printer?).to eq true
    end
  end
end
