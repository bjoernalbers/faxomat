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
      :content,
      :username,
      :patient_number,
      :patient_first_name,
      :patient_last_name,
      :patient_date_of_birth
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
    end
  end
end
