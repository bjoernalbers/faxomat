module API
  describe Report do
    let(:report) { build(:api_report) }

    it 'has valid factory' do
      report = build(:api_report)
      expect(report).to be_valid
    end

    # Required attributes
    [
      :subject,
      :username,
      :patient_number,
      :patient_first_name,
      :patient_last_name,
      :patient_date_of_birth,
      :anamnesis,
      :evaluation,
      :procedure
    ].each do |attr|
      it { expect(report).to validate_presence_of(attr) }
    end

    it 'validates existence of username' do
      report.username = 'thisuserdoesnotexist'
      expect(report).to be_invalid
      expect(report.errors[:username]).to be_present
    end

    it 'saves report' do
      report = build(:api_report)
      expect{report.save}.to change(::Report, :count).by(1)
    end

    describe '#id' do
      it 'gets delegated to ::Report#id' do
        allow(report).to receive(:report).and_return( double(id: 42) )
        expect(report.id).to eq 42
      end
    end

    describe '#patient_sex' do
      it { expect(report).to allow_value('m', 'M', 'w', 'W', 'u', 'U', nil, '').
        for(:patient_sex) }

      it { expect(report).not_to allow_value('Frau', 'Mann', 0, 1, 2, 3).
        for(:patient_sex) }
    end

    describe '.value_to_gender' do
      it 'accepts values for :male' do
        [ 'm', 'M' ].each do |sex|
          gender = Report.value_to_gender(sex)
          expect(gender).to eq :male
        end
      end

      it 'accepts values for :female' do
        [ 'w', 'W', 'f', 'F' ].each do |sex|
          gender = Report.value_to_gender(sex)
          expect(gender).to eq :female
        end
      end

      it 'returns nil for everything else' do
        [ '', nil, 'u', 'U', 'o', 'O' ].each do |sex|
          gender = Report.value_to_gender(sex)
          expect(gender).to be nil
        end
      end
    end

    context 'when saved' do
      it 'creates patient' do
        report = build(:api_report,
                       patient_number:        '42',
                       patient_first_name:    'Chuck',
                       patient_last_name:     'Norris',
                       patient_date_of_birth: '1940-03-10',
                       patient_sex:           'm',
                       patient_title:         'Mr.',
                       patient_suffix:        "(yes, it's him!)")
        report.save!
        patient = report.patient

        expect(patient).to be_persisted
        expect(patient.patient_number).to eq '42'
        expect(patient.first_name).to eq     'Chuck'
        expect(patient.last_name).to eq      'Norris'
        expect(patient.date_of_birth).to eq  Time.zone.parse('1940-03-10')
        expect(patient).to                   be_male
        expect(patient.title).to eq          'Mr.'
        expect(patient.suffix).to eq         "(yes, it's him!)"
      end

      it 'creates recipient' do
        report = build(:api_report,
                       recipient_last_name:  'House',
                       recipient_first_name: 'Gregory',
                       recipient_sex:        'm',
                       recipient_title:      'Dr.',
                       recipient_suffix:     'MD',
                       recipient_address:    'Sesamstraße 42',
                       recipient_zip:        '98765',
                       recipient_city:       'Hollywood')
        report.save!
        recipient = report.recipient

        expect(recipient).to be_persisted
        expect(recipient.last_name).to eq  'House'
        expect(recipient.first_name).to eq 'Gregory'
        expect(recipient.title).to eq      'Dr.'
        expect(recipient.suffix).to eq     'MD'
        expect(recipient.address).to eq    'Sesamstraße 42'
        expect(recipient.zip).to eq        '98765'
        expect(recipient.city).to eq       'Hollywood'
        expect(recipient).to               be_male
      end

      it 'creates fax number' do
        report = build(:api_report,
                       recipient_fax_number: '0123456789')
        report.save!
        fax_number = report.fax_number

        expect(fax_number).to be_persisted
        expect(fax_number.fax_number).to eq '0123456789'
      end
    end
  end
end
