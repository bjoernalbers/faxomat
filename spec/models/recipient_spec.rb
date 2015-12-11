describe Recipient do
  let(:recipient) { build(:recipient) }

  # Required attributes
  it { expect(recipient).to validate_presence_of(:last_name) }

  # Optional attributes
  [ :first_name, :title, :suffix, :salutation, :address, :zip, :city ].each do |attr|
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

  describe '#fax_number_string' do
    it 'returns fax number as string' do
      allow(recipient).to receive(:fax_number).
        and_return double(to_s: '0123456789')
      expect(recipient.fax_number_string).to eq '0123456789'
    end
  end
end
