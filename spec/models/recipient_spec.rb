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

  describe '#full_name' do
    it 'joins title, first and last name' do
      recipient = build(:recipient,
                        title:      'Dr.',
                        first_name: 'Julius M.',
                        last_name:  'Hibbert')
      expect(recipient.full_name).to eq 'Dr. Julius M. Hibbert'
    end
  end

  describe '#full_address' do
    it 'array of full name, suffix, address, zip and city' do
      recipient = build(:recipient,
                        suffix: 'Simpsons-Hausarzt',
                        address: 'Sesamstraße 1',
                        zip: '12345',
                        city: 'Springfield')
      allow(recipient).to receive(:full_name).and_return('Dr. Julius M. Hibbert')
      expect(recipient.full_address).to eq [
        'Dr. Julius M. Hibbert',
        'Simpsons-Hausarzt',
        'Sesamstraße 1',
        '12345 Springfield' ]
    end
  end

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
