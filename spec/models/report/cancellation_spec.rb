describe Report::Cancellation do
  subject { build(:report_cancellation) }
  let(:other) { create(:report_cancellation) }

  it_behaves_like 'status change'

  it 'is translated' do
    expect(described_class.model_name.human).to eq 'Stornierung'
  end

  describe '#report' do
    it 'must be verified' do
      subject = build(:report_cancellation, report: create(:pending_report))
      expect(subject).to be_invalid
      expect(subject.errors[:report]).to be_present
      subject = build(:report_cancellation, report: create(:verified_report))
      expect(subject).to be_valid
    end
  end

  context 'on create' do
    let(:report) { create(:verified_report) }
    let(:document) { create(:document, report: report) }

    it 'updates report documents' do
      old_fingerprint = document.fingerprint
      create(:report_cancellation, report: report)
      document.reload
      expect(document.fingerprint).not_to eq(old_fingerprint)
    end
  end
end
