describe Report::Release do
  subject { build(:report_release) }
  let(:other) { create(:report_release) }

  it_behaves_like 'status change'

  it 'is translated' do
    expect(described_class.model_name.human).to eq 'Vidierung'
  end

  describe '#create' do
    let(:report) { create(:report) }
    let(:document) { create(:document, report: report) }

    it 'updates report documents' do
      old_fingerprint = document.fingerprint
      create(:report_release, report: report)
      document.reload
      expect(document.fingerprint).not_to eq(old_fingerprint)
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

    it 'updates report documents'
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

    it 'updates report documents'
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
