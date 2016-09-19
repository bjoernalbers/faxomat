describe Report::Release do
  subject { build(:report_release) }
  let(:other) { create(:report_release) }

  it_behaves_like 'status change'

  it 'is translated' do
    expect(described_class.model_name.human).to eq 'Vidierung'
  end

  context 'on create' do
    let(:report) { create(:report) }
    let(:document) { create(:document, report: report) }

    it 'updates report documents' do
      old_fingerprint = document.fingerprint
      create(:report_release, report: report)
      document.reload
      expect(document.fingerprint).not_to eq(old_fingerprint)
    end
  end
end
