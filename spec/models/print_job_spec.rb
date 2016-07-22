describe PrintJob do
  let(:subject) { build(:print_job) }

  it 'has valid factory' do
    expect(subject).to be_valid
  end

  describe '#number' do
    it 'must be present' do
      subject.number = nil
      expect(subject).to be_invalid
      expect(subject.errors[:number]).to be_present
      expect {
        subject.save!(validate: false)
      }.to raise_error(ActiveRecord::ActiveRecordError)
    end

    it 'must be unique' do
      subject.number = create(:print_job).number
      expect(subject).to be_invalid
      expect(subject.errors[:number]).to be_present
      expect {
        subject.save!(validate: false)
      }.to raise_error(ActiveRecord::ActiveRecordError)
    end
  end

  describe '#fax_number' do
    include_examples 'should validate fax_number'

    it 'does not validate presence' do
      [nil, ''].each do |attr|
        subject.fax_number = attr
        expect(subject).to be_valid
      end
    end
  end

  describe '#printer' do
    it 'must be present' do
      subject.printer = nil
      expect(subject).to be_invalid
      expect(subject.errors[:printer]).to be_present
      expect {
        subject.save!(validate: false)
      }.to raise_error(ActiveRecord::ActiveRecordError)
    end
  end

  describe '#delivery' do
    it 'should just have one :-)'
  end
end
