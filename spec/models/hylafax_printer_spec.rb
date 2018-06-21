describe HylafaxPrinter do
  let(:subject) { build(:hylafax_printer) }

  it 'has valid factory' do
    expect(subject).to be_valid
    expect(subject).to be_a described_class
  end

  describe '.default' do
    let(:subject) { described_class.default }

    it 'returns first fax printer' do
      first, second = create_pair(:hylafax_printer)
      expect(subject).to eq described_class.first
    end
  end

  describe '#is_fax_printer?' do
    it 'returns true' do
      expect(subject.is_fax_printer?).to eq true
    end
  end

  describe '#host' do
    it 'must be present' do
      subject.host = nil
      expect(subject).to be_invalid
      expect(subject.errors[:host]).to be_present
    end

    it 'defaults to "127.0.0.1"' do
      expect(subject.host).to eq '127.0.0.1'
    end
  end

  describe '#port' do
    it 'must be present' do
      subject.port = nil
      expect(subject).to be_invalid
      expect(subject.errors[:port]).to be_present
    end

    it 'defaults to 4559' do
      expect(subject.port).to eq 4559
    end
  end

  describe '#user' do
    it 'must be present' do
      subject.user = nil
      expect(subject).to be_invalid
      expect(subject.errors[:user]).to be_present
    end

    it 'defaults to "anonymous"' do
      expect(subject.user).to eq 'anonymous'
    end
  end

  describe '#password' do
    it 'must be present' do
      subject.password = nil
      expect(subject).to be_invalid
      expect(subject.errors[:password]).to be_present
    end

    it 'defaults to "anonymous"' do
      expect(subject.password).to eq 'anonymous'
    end
  end
end
