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
end
