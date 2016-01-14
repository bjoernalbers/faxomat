describe Report do
  let(:report) { build(:report) }

  # Associations
  [ :user, :patient, :recipient ].each do |association|
    it { expect(report).to belong_to(association) }
  end

  it { expect(report).to have_many(:faxes) }

  # Required attributes
  [
    :user,
    :patient,
    :recipient,
    :anamnesis,
    :evaluation,
    :procedure,
    :study,
    :study_date
  ].each do |attribute|
    it { expect(report).to validate_presence_of(attribute) }
  end

  # Optional attributes
  [
    :diagnosis,
    :findings,
    :clinic,
    :verified_at,
    :canceled_at
  ].each do |attribute|
    it { expect(report).not_to validate_presence_of(attribute) }
  end

  describe '.pending' do
    let(:now) { Time.zone.now }

    it 'returns all pending reports' do
      pending = create(:report, verified_at: nil, canceled_at: nil)
      approved = create(:report, verified_at: now, canceled_at: nil)
      canceled = create(:report, verified_at: now, canceled_at: now)
      expect(Report.pending.all).to eq  [ pending ]
    end
  end

  describe '#approved!' do
    it 'sets status to approved' do
      expect(report).not_to be_approved
      report.approved!
      expect(report).to be_approved
    end
  end

  describe '#canceled!' do
    it 'sets status to canceled' do
      expect(report).not_to be_canceled
      report.canceled!
      expect(report).to be_canceled
    end
  end

  describe '#pending!' do
    it 'sets status to pending' do
      report.approved!
      expect(report).not_to be_pending
      report.pending!
      expect(report).to be_pending
    end
  end

  describe '#status' do
    let(:now) { Time.zone.now }

    context 'when initialized' do
      let(:report) { build(:report) }

      it 'is pending' do
        expect(report.status).to eq 'pending'
        expect(report).to be_pending
      end
    end

    context 'when not verified and not canceled' do
      let(:report) { build(:report, verified_at: nil, canceled_at: nil) }

      it 'is pending by default' do
        expect(report.status).to eq 'pending'
        expect(report).to be_pending
      end
    end

    context 'when verified and not canceled' do
      let(:report) { build(:report, verified_at: now, canceled_at: nil) }

      it 'is approved' do
        expect(report.status).to eq 'approved'
        expect(report).to be_approved
      end
    end

    context 'when verified and canceled' do
      let(:report) { build(:report, verified_at: now, canceled_at: now) }

      it 'is canceled' do
        expect(report.status).to eq 'canceled'
        expect(report).to be_canceled
      end
    end
  end

  describe '#subject' do
    it 'joins study and study date' do
      report = build(:report, study: 'MRT des Kopfes', study_date: '2016-01-01')
      expect(report.subject).to eq 'MRT des Kopfes vom 1.1.2016'
    end
  end

  describe '#title' do
    it 'returns patient display name' do
      expect(report.title).to eq report.patient.display_name
    end
  end

  describe '#deliver_as_fax' do
    it 'delivers itself as fax' do
      allow(ReportFaxer).to receive(:deliver)
      report.deliver_as_fax
      expect(ReportFaxer).to have_received(:deliver).with(report)
    end
  end
end
