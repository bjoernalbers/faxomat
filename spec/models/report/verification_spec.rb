describe Report::Verification do
  subject { create(:report_verification) }

  it 'is translated' do
    expect(described_class.model_name.human).to eq 'Vidierung'
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

    it 'must be unique' do
      subject.report = create(:report_verification).report
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
  end

  context 'on create' do
    let(:report) { create(:report) }
    let(:document) { create(:document, report: report) }

    it 'updates report documents' do
      old_fingerprint = document.fingerprint
      create(:report_verification, report: report)
      document.reload
      expect(document.fingerprint).not_to eq(old_fingerprint)
    end
  end
end
