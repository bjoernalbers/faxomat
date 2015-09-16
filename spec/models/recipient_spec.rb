describe Recipient do
  let(:recipient) { build(:recipient) }

  # Required attributes
  it { expect(recipient).to validate_presence_of(:last_name) }

  # Optional attributes
  [ :first_name, :title, :suffix, :sex, :address, :zip, :city ].each do |attr|
    it { expect(recipient).not_to validate_presence_of(attr) }
  end

  # Associations
  it { expect(recipient).to belong_to(:fax_number) }

  describe '#sex' do
    it 'accepts 0 as male' do
      recipient.sex = 0
      expect(recipient).to be_valid
      expect(recipient).to be_male
    end

    it 'accepts 1 as female' do
      recipient.sex = 0
      expect(recipient).to be_valid
      expect(recipient).to be_male
    end

    it 'accepts no unknown values' do
      expect{ recipient.sex = 2 }.to raise_error(ArgumentError)
    end
  end
end
