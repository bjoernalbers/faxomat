describe Patient do
  let(:patient) { build(:patient) }

  # Required attributes
  [ :first_name, :last_name, :date_of_birth, :number ].each do |attr|
    it { expect(patient).to validate_presence_of(attr) }
  end

  # Optional attributes
  [ :title, :suffix, :sex ].each do |attr|
    it { expect(patient).not_to validate_presence_of(attr) }
  end

  it 'is translated' do
    expect(described_class.model_name.human).to eq 'Patient'
    {
      first_name:    'Vorname',
      last_name:     'Nachname',
      date_of_birth: 'Geburtsdatum',
      title:         'Titel',
      suffix:        'Namenszusatz',
      sex:           'Geschlecht',
      number:        'Nummer'
    }.each do |attr,translation|
      expect(described_class.human_attribute_name(attr)).to eq translation
    end
  end

  describe '#sex' do
    it 'accepts 0 as male' do
      patient.sex = 0
      expect(patient).to be_valid
      expect(patient).to be_male
    end

    it 'accepts 1 as female' do
      patient.sex = 0
      expect(patient).to be_valid
      expect(patient).to be_male
    end

    it 'accepts no unknown values' do
      expect{ patient.sex = 2 }.to raise_error(ArgumentError)
    end
  end

  describe '#number' do
    it 'does not store leading and trailing whitespaces' do
      patient.update(number: " 42\t ")
      patient.reload
      expect(patient.number).to eq '42'
    end
  end

  describe '#display_name' do
    it 'returns full name and date of birth' do
      patient = build(:patient,
                      first_name: 'Chunky',
                      last_name: 'Bacon',
                      title: nil,
                      date_of_birth: '1970-2-1')
      expect(patient.display_name).to eq 'Chunky Bacon (* 1.2.1970)'
    end

    it 'includes title when present' do
      patient = build(:patient,
                      first_name: 'Chunky',
                      last_name: 'Bacon',
                      title: 'Mr.',
                      date_of_birth: '1970-2-1')
      expect(patient.display_name).to eq 'Mr. Chunky Bacon (* 1.2.1970)'
    end
  end

  describe '#to_s' do
    it 'returns display name' do
      expect(patient.to_s).to eq patient.display_name
    end
  end
end
