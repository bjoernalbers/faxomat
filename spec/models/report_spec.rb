describe Report do
  let(:report) { build(:report) }

  it { expect(report).to belong_to(:user) }

  # Required attributes
  [ :subject, :content, :user ].each do |attr|
    it { expect(report).to validate_presence_of(attr) }
  end
end
