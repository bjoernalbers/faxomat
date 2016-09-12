describe Report::Verification do
  subject { build(:report_verification) }
  let(:other) { create(:report_verification) }

  it_behaves_like 'status change'

  it 'is translated' do
    expect(described_class.model_name.human).to eq 'Vidierung'
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
