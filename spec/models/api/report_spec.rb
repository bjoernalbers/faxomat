module API
  describe Report do
    let(:subject) { build(:api_report) }

    it 'has valid factory' do
      subject = build(:api_report)
      expect(subject).to be_valid
    end

    it 'validates patient' do
      patient = build(:patient, last_name: nil)
      subject.patient = patient
      expect(patient).to be_invalid
      expect(subject).to be_invalid
      expect(subject.errors[:patient]).to be_present
    end

    it 'validates recipient' do
      recipient = build(:recipient, last_name: nil)
      subject.recipient = recipient
      expect(recipient).to be_invalid
      expect(subject).to be_invalid
      expect(subject.errors[:recipient]).to be_present
    end

    it 'validates report' do
      report = build(:report, study: nil)
      subject.report = report
      expect(report).to be_invalid
      expect(subject).to be_invalid
      expect(subject.errors[:report]).to be_present
    end

    describe '.find' do
      context 'with existing report' do
        let(:report) { create(:report) }
        let(:subject) { API::Report.find(report.id) }

        it 'returns API::Report instance' do
          expect(subject).to be_a API::Report
        end

        it 'assigns report to API::Report instance' do
          expect(subject.report).to eq report
        end
      end

      context 'with unknown report' do
        let(:subject) { API::Report.find(234234234234) }

        it 'raises exception' do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end

    describe '#save!' do
      before do
        allow(subject).to receive(:save).and_return(true)
      end

      it 'calls save' do
        subject.save!
        expect(subject).to have_received(:save)
      end

      context 'when saveable' do
        it 'returns true' do
          expect(subject.save!).to eq true
        end
      end

      context 'when not saveable' do
        it 'raises exception' do
          allow(subject).to receive(:save).and_return(false)
          expect { subject.save! }.to raise_error('Speicherung fehlgeschlagen')
        end
      end
    end

    describe '#save' do
      context 'when valid' do
        before { allow(subject).to receive(:valid?).and_return(true) }

        it 'saves report' do
          expect { subject.save }.to change(::Report, :count).by(1)
        end

        it 'returns true' do
          expect(subject.save).to eq true
        end
      end

      context 'when invalid' do
        before { allow(subject).to receive(:valid?).and_return(false) }

        it 'returns false' do
          expect(subject.save).to eq false
        end
      end
    end

    describe '#build_report' do
      context 'without report' do
        before { subject.report = nil }

        it 'returns new report' do
          expect(subject.send(:build_report)).to be_new_record
        end
      end

      context 'with report' do
        let(:report) { build(:report) }
        before { subject.report = report }

        it 'returns assigned report' do
          expect(subject.send(:build_report)).to eq report
        end
      end

      it 'assigns reports attributes to report' do
        allow(subject).to receive(:report_attributes).
          and_return({findings: 'nix'})
        expect(subject.send(:build_report).findings).to eq 'nix'
      end
    end

    describe '#report' do
      let(:report) { build(:report) }

      before { allow(subject).to receive(:build_report).and_return(report) }

      it 'builds report' do
        expect(report).to eq report
      end

      it 'caches report' do
        2.times { subject.report }
        expect(subject).to have_received(:build_report).once
      end
    end

    describe '#patient' do
      let(:patient) { build(:patient) }

      before do
        allow(subject).to receive(:find_or_create_patient).and_return(patient)
      end

      it 'finds / creates and returns patient' do
        expect(subject.patient).to eq patient
      end

      it 'caches patient' do
        2.times { subject.patient }
        expect(subject).to have_received(:find_or_create_patient).once
      end
    end

    describe '#recipient' do
      let(:recipient) { build(:recipient) }

      before do
        allow(subject).to receive(:find_or_create_recipient).and_return(recipient)
      end

      it 'finds / creates and returns recipient' do
        expect(subject.recipient).to eq recipient
      end

      it 'caches recipient' do
        2.times { subject.recipient }
        expect(subject).to have_received(:find_or_create_recipient).once
      end
    end

    describe '#user' do
      it 'validates presence' do
        expect(subject).to validate_presence_of(:user)
      end

      context 'when initializes with existing username' do
        let(:user) { create(:user) }
        let(:subject) { API::Report.new(username: user.username) }

        it 'returns user' do
          expect(subject.user).to eq user
        end
      end

      context 'when initializes with unknown username' do
        let(:subject) { API::Report.new(username: 'unknown-user') }

        it 'returns nil' do
          expect(subject.user).to be nil
        end
      end
    end

    context 'on save when study includes date prefix' do
      let(:subject) { build(:api_report,
                           study_date: nil,
                           study:      '01.12.1980: Party: Yes!') }

      before do
        subject.save
      end

      it 'stores the date as study date' do
        expect(subject.study_date).to eq '01.12.1980'
      end

      it 'removes the date prefix from study' do
        expect(subject.study).to eq 'Party: Yes!'
      end
    end

    # Required attributes
    [
      :patient_number,
      :patient_first_name,
      :patient_last_name,
      :patient_date_of_birth,
      :anamnesis,
      :evaluation,
      :procedure,
      :study,
      :study_date
    ].each do |attr|
      it { expect(subject).to validate_presence_of(attr) }
    end

    it 'saves report' do
      subject = build(:api_report)
      expect{subject.save}.to change(::Report, :count).by(1)
    end

    describe '#id' do
      it 'gets delegated to ::Report#id' do
        allow(subject).to receive(:report).and_return( double(id: 42) )
        expect(subject.id).to eq 42
      end
    end

    describe '#patient_sex' do
      it { expect(subject).to allow_value('m', 'M', 'w', 'W', 'u', 'U', nil, '').
        for(:patient_sex) }

      it { expect(subject).not_to allow_value('Frau', 'Mann', 0, 1, 2, 3).
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

    describe '#attributes=' do
      it 'assigns attributes' do
        subject.attributes = {
          'patient_first_name' => 'Chunky',
          patient_last_name: 'Bacon'
        }
        expect(subject.patient_first_name).to eq 'Chunky'
        expect(subject.patient_last_name).to eq 'Bacon'
      end
    end

    context 'when saved' do
      it 'creates patient' do
        subject = build(:api_report,
                       patient_number:        '42',
                       patient_first_name:    'Chuck',
                       patient_last_name:     'Norris',
                       patient_date_of_birth: '1940-03-10',
                       patient_sex:           'm',
                       patient_title:         'Mr.',
                       patient_suffix:        "(yes, it's him!)")
        subject.save!
        patient = subject.patient

        expect(patient).to be_persisted
        expect(patient.number).to eq '42'
        expect(patient.first_name).to eq     'Chuck'
        expect(patient.last_name).to eq      'Norris'
        expect(patient.date_of_birth).to eq  Time.zone.parse('1940-03-10')
        expect(patient).to                   be_male
        expect(patient.title).to eq          'Mr.'
        expect(patient.suffix).to eq         "(yes, it's him!)"
      end

      it 'creates recipient' do
        subject = build(:api_report,
                       recipient_last_name:  'House',
                       recipient_first_name: 'Gregory',
                       recipient_salutation: 'Hallihallo,',
                       recipient_title:      'Dr.',
                       recipient_suffix:     'MD',
                       recipient_address:    'Sesamstraße 42',
                       recipient_zip:        '98765',
                       recipient_city:       'Hollywood',
                       recipient_fax_number: '0123456789')
        subject.save!
        recipient = subject.recipient

        expect(recipient).to be_persisted
        expect(recipient.last_name).to eq  'House'
        expect(recipient.first_name).to eq 'Gregory'
        expect(recipient.title).to eq      'Dr.'
        expect(recipient.suffix).to eq     'MD'
        expect(recipient.address).to eq    'Sesamstraße 42'
        expect(recipient.zip).to eq        '98765'
        expect(recipient.city).to eq       'Hollywood'
        expect(recipient.salutation).to eq 'Hallihallo,'
        expect(recipient.fax_number).to eq '0123456789'
      end

      it 'creates report' do
        subject = build(:api_report, findings: 'chunky')
        expect { subject.save! }.to change(::Report, :count).by(1)
        report = subject.report
        expect(report.findings).to eq 'chunky'
      end
    end
  end
end
