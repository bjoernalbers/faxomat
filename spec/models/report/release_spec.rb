describe Report::Release do
  subject { build(:report_release) }
  let(:other) { create(:report_release) }

  it 'is translated' do
    expect(described_class.model_name.human).to eq 'Berichtfreigabe'
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
      subject.report = other.report
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

  describe '#create' do
    let(:report) { create(:report) }
    let(:document) { create(:document, report: report) }

    it 'updates report documents' do
      expect {
        create(:report_release, report: report)
      }.to change { document.reload.fingerprint }
    end
  end

  describe '#destroy' do
    subject { create(:report_release) }

    it 'soft-deletes record' do
      expect(subject).not_to be_deleted
      subject.destroy
      expect(subject).to be_deleted
      expect(subject).to be_persisted
    end

    it 'updates report documents' do
      document = create(:document, report: subject.report)
      expect { subject.destroy }.to change { document.reload.fingerprint }
    end
  end

  describe '#restore' do
    subject { create(:report_release) }

    before do
      subject.destroy
    end

    it 'un-deletes record' do
      expect(subject).to be_deleted
      subject.restore
      expect(subject).not_to be_deleted
    end

    it 'updates report documents' do
      document = create(:document, report: subject.report)
      expect { subject.restore }.to change { document.reload.fingerprint }
    end
  end

  describe 'default scope' do
    subject { described_class.all }
    let(:record) { create(:report_release) }

    before { record.destroy }

    it 'excludes soft-deleted records' do
      expect(subject).not_to include(record)
    end
  end
end
