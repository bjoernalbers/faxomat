describe Recipient do
  let(:recipient) { build(:recipient) }

  it 'has valid factory' do
    expect(recipient).to be_valid
    %i(title first_name last_name suffix fax_number salutation address).each do |attr|
      expect(recipient.send(attr)).to be_present
    end
  end

  # Optional attributes
  [ :first_name, :last_name, :title, :suffix, :salutation, :fax_number ].each do |attr|
    it { expect(recipient).not_to validate_presence_of(attr) }
  end

  it { should belong_to(:address) }

  context '#street' do
    it { should delegate_method(:street).to(:address) }

    it 'returns nil without address' do
      recipient = build(:recipient, address: nil)
      expect(recipient.street).to be nil
    end
  end

  context '#zip' do
    it { should delegate_method(:zip).to(:address) }

    it 'returns nil without address' do
      recipient = build(:recipient, address: nil)
      expect(recipient.zip).to be nil
    end
  end

  context '#city' do
    it { should delegate_method(:city).to(:address) }

    it 'returns nil without address' do
      recipient = build(:recipient, address: nil)
      expect(recipient.city).to be nil
    end
  end

  describe '#salutation' do
    context 'when missing' do
      let(:recipient) { build(:recipient, salutation: '') }

      it 'returns default salutation' do
        expect(recipient.salutation).to eq 'Sehr geehrte Kollegen,'
      end
    end

    context 'when present' do
      let(:recipient) { build(:recipient, salutation: 'Hallo Leute,') }

      it 'returns recipient salutation' do
        expect(recipient.salutation).to eq 'Hallo Leute,'
      end
    end
  end

  it 'is translated' do
    expect(described_class.model_name.human).to eq 'Überweiser'
    {
      first_name:    'Vorname',
      last_name:     'Nachname',
      title:         'Titel',
      suffix:        'Namenszusatz',
      salutation:    'Anrede',
      fax_number:    'Faxnummer',
      address:       'Adresse'
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

    it 'excludes blank elements' do
      recipient = build(:recipient,
                        title:      'Dr.',
                        first_name: '',
                        last_name:  'Hibbert')
      expect(recipient.full_name).to eq 'Dr. Hibbert'
    end
  end

  describe '#full_address' do
    let(:address) { build(:address,
                          street: 'Sesamstraße 1',
                          zip:    '12345',
                          city:   'Springfield') }
    let(:recipient) { build(:recipient,
                             suffix: 'Simpsons-Hausarzt',
                             address: address) }

    before do
      allow(recipient).to receive(:full_name).and_return('Dr. Julius M. Hibbert')
    end

    it 'array of full name, suffix, street, zip and city' do
      expect(recipient.full_address).to eq [
        'Dr. Julius M. Hibbert',
        'Simpsons-Hausarzt',
        'Sesamstraße 1',
        '12345 Springfield'
      ]
    end

    it 'returns array of full name and suffix when without address' do
      recipient.address = nil
      expect(recipient.full_address).to eq [
        'Dr. Julius M. Hibbert',
        'Simpsons-Hausarzt'
      ]
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

  describe '#send_with_hylafax' do
    it 'defaults to false' do
      subject = described_class.new
      expect(subject.send_with_hylafax).to eq false
    end

    it 'can be set to true' do
      subject = described_class.new(send_with_hylafax: true)
      expect(subject.send_with_hylafax).to eq true
    end
  end
end
