describe Recipient do
  let(:recipient) { build(:recipient) }

  it 'has valid factory' do
    expect(recipient).to be_valid
    %i(title first_name last_name suffix address city zip fax_number salutation).each do |attr|
      expect(recipient.send(attr)).to be_present
    end
  end

  # Required attributes
  it { expect(recipient).to validate_presence_of(:last_name) }

  # Optional attributes
  [ :first_name, :title, :suffix, :salutation, :address, :zip, :city, :fax_number ].each do |attr|
    it { expect(recipient).not_to validate_presence_of(attr) }
  end

  it { expect(recipient).to have_many(:reports) }

  it 'is translated' do
    expect(described_class.model_name.human).to eq 'Überweiser'
    {
      first_name:    'Vorname',
      last_name:     'Nachname',
      title:         'Titel',
      suffix:        'Namenszusatz',
      address:       'Adresse',
      zip:           'Postleitzahl',
      city:          'Ort',
      salutation:    'Anrede',
      fax_number:    'Faxnummer'
    }.each do |attr,translation|
      expect(described_class.human_attribute_name(attr)).to eq translation
    end
  end

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

  describe '#fax_number' do
    it 'is valid when nil' do
      recipient.fax_number = nil
      expect(recipient).to be_valid
    end

    it 'is valid when empty' do
      recipient.fax_number = ''
      expect(recipient).to be_valid
    end

    it 'drops nondigits before validation' do
      recipient = build(:recipient, fax_number: ' 0123-456 789 ')
      expect(recipient).to be_valid
      expect(recipient.fax_number).to eq '0123456789'
    end

    it 'is invalid when to short' do
      recipient = build(:recipient, fax_number: '0123456')
      expect(recipient).to be_invalid
      expect(recipient.errors[:fax_number]).to be_present
    end

    it 'is invalid without leading zero' do
      recipient = build(:recipient, fax_number: '123456789')
      expect(recipient).to be_invalid
      expect(recipient.errors[:fax_number]).to be_present
    end

    it 'is invalid with multiple leading zeros' do
      recipient = build(:recipient, fax_number: '00123456789')
      expect(recipient).to be_invalid
      expect(recipient.errors[:fax_number]).to be_present
    end
  end
end
