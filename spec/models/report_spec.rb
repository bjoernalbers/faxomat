describe Report do
  let(:report) { build(:report) }

  # Associations
  [ :user, :patient ].each do |association|
    it { expect(report).to belong_to(association) }
  end

  # Required attributes
  [ :subject, :content, :user, :patient ].each do |attribute|
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

    it 'accepts 0 as approved' do
      report.status = 1
      expect(report).to be_approved
    end
  end
end
