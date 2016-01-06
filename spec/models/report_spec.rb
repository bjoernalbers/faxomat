describe Report do
  let(:report) { build(:report) }

  # Associations
  [ :user, :patient, :recipient ].each do |association|
    it { expect(report).to belong_to(association) }
  end

  # Required attributes
  [
    :user,
    :patient,
    :recipient,
    :anamnesis,
    :evaluation,
    :procedure
  ].each do |attribute|
    it { expect(report).to validate_presence_of(attribute) }
  end

  describe '#status' do
    it 'defaults to pending' do
      expect(report).to be_pending
    end

    it 'accepts 0 as pending' do
      report.status = 0
      expect(report).to be_pending
    end

    it 'accepts 1 as approved' do
      report.status = 1
      expect(report).to be_approved
    end

    it 'accepts 2 as canceled' do
      report.status = 2
      expect(report).to be_canceled
    end
  end

  describe '#subject' do
    it 'is an alias for study' do
      expect(report.subject).to eq report.study
      report.study = 'chunky bacon'
      expect(report.subject).to eq report.study
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
