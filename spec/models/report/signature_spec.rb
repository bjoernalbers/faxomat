describe Report::Signature do
  subject { build(:report_signature) }
  let(:other) { create(:report_signature) }

  it 'is translated' do
    expect(described_class.model_name.human).to eq 'Unterschrift'
  end

  describe '#report' do
    it 'is translated' do
      expect(described_class.human_attribute_name(:report)).to eq 'Bericht'
    end

    it { should belong_to(:report) }

    it 'must be present' do
      subject.report = nil
      expect(subject).to be_invalid
      expect(subject.errors[:report]).to be_present
      expect {
        subject.save!(validate: false)
      }.to raise_error(ActiveRecord::ActiveRecordError)
    end
  end

  describe '#user' do
    it 'is translated' do
      expect(described_class.human_attribute_name(:user)).to eq 'Arzt'
    end

    it { should belong_to(:user) }

    it 'must be present' do
      subject.user = nil
      expect(subject).to be_invalid
      expect(subject.errors[:user]).to be_present
      expect {
        subject.save!(validate: false)
      }.to raise_error(ActiveRecord::ActiveRecordError)
    end

    it 'can be non-unique' do
      subject.user = other.user
      expect(subject).to be_valid
      expect {
        subject.save!(validate: false)
      }.not_to raise_error(ActiveRecord::ActiveRecordError)
    end

    it 'must not have signed report' do
      subject.attributes = { report: other.report, user: other.user }
      expect(subject).to be_invalid
      expect(subject.errors[:user]).to include('hat Bericht bereits unterschrieben')
      expect {
        subject.save!(validate: false)
      }.to raise_error(ActiveRecord::ActiveRecordError)
    end
  end
end
