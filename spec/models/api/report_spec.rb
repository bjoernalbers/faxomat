module API
  describe Report do
    let(:subject) { build(:api_report) }

    it 'has valid factory' do
      subject = build(:api_report)
      expect(subject).to be_valid
    end

    it 'is translated' do
      expect(described_class.model_name.human).to eq 'Bericht'
      {
        user:       'Arzt',
        patient:    'Patient',
        study:      'Untersuchung',
        study_date: 'Untersuchungsdatum',
        anamnesis:  'Indikation',
        findings:   'Befund',
        evaluation: 'Beurteilung',
        procedure:  'Methode',
        clinic:     'Klinik',
        report:     'Bericht'
      }.each do |attr,translation|
        expect(described_class.human_attribute_name(attr)).to eq translation
      end
    end

    [
      :patient_number,
      :patient_first_name,
      :patient_last_name,
      :patient_date_of_birth,
      :recipient_last_name,
      :recipient_street,
      :recipient_zip,
      :recipient_city,
      :study,
      :study_date,
      :anamnesis,
      :evaluation,
      :procedure
    ].each do |attribute|
      it { should validate_presence_of(attribute) }
    end

    describe '#patient_street' do
      it 'with send_report_to_patient=true validates presence' do
        subject = build(:api_report, send_report_to_patient: true,
                        patient_street: nil)
        expect(subject).to be_invalid
        expect(subject.errors[:patient_street]).to be_present
      end

      it 'with send_report_to_patient=false does not validate presence' do
        subject = build(:api_report, send_report_to_patient: false,
                        patient_street: nil)
        expect(subject).to be_valid
      end
    end

    describe '#patient_zip' do
      it 'with send_report_to_patient=true validates presence' do
        subject = build(:api_report, send_report_to_patient: true,
                        patient_zip: nil)
        expect(subject).to be_invalid
        expect(subject.errors[:patient_zip]).to be_present
      end

      it 'with send_report_to_patient=false does not validate presence' do
        subject = build(:api_report, send_report_to_patient: false,
                        patient_zip: nil)
        expect(subject).to be_valid
      end
    end

    describe '#patient_city' do
      it 'with send_report_to_patient=true validates presence' do
        subject = build(:api_report, send_report_to_patient: true,
                        patient_city: nil)
        expect(subject).to be_invalid
        expect(subject.errors[:patient_city]).to be_present
      end

      it 'with send_report_to_patient=false does not validate presence' do
        subject = build(:api_report, send_report_to_patient: false,
                        patient_city: nil)
        expect(subject).to be_valid
      end
    end

    it 'validates format of fax number' do
      subject = build(:api_report, recipient_fax_number: '98786')
      expect(subject).to be_invalid
      expect(subject.errors[:recipient_fax_number]).to be_present
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

    describe '#save' do
      before do
        allow(subject).to receive(:save_records!)
      end

      context 'when invalid' do
        before do
          allow(subject).to receive(:valid?).and_return(false)
        end

        it 'does not save records' do
          subject.save
          expect(subject).not_to have_received(:save_records!)
        end

        it 'returns false' do
          expect(subject.save).to eq false
        end
      end

      context 'when valid' do
        before do
          allow(subject).to receive(:valid?).and_return(true)
        end

        it 'saves records' do
          subject.save
          expect(subject).to have_received(:save_records!)
        end

        it 'returns true' do
          expect(subject.save).to eq true
        end

        it 'returns false if ActiveRecordError was raised' do
          allow(subject).to receive(:save_records!).
            and_raise(ActiveRecord::ActiveRecordError)
          expect(subject.save).to eq false
        end
      end
    end

    describe '#save_records!' do
      def do_save_records
        subject.send(:save_records!)
      end

      it 'creates address when not present' do
        expect { do_save_records }.to change { Address.count }.by(1)
      end

      it 'does not create address when present' do
        create(:address,
          street: subject.recipient_street,
          zip:    subject.recipient_zip,
          city:   subject.recipient_city)
        expect { do_save_records }.not_to change { Address.count }
      end

      it 'creates recipient when not present' do
        expect { do_save_records }.to change { Recipient.count }.by(1)
      end

      it 'does not create recipient when present' do
        address = create(:address,
          street: subject.recipient_street,
          zip:    subject.recipient_zip,
          city:   subject.recipient_city)
        recipient = create(:recipient, address: address,
          last_name:  subject.recipient_last_name,
          first_name: subject.recipient_first_name,
          salutation: subject.recipient_salutation,
          title:      subject.recipient_title,
          suffix:     subject.recipient_suffix,
          fax_number: subject.recipient_fax_number)
        expect { do_save_records }.not_to change { Recipient.count }
      end

      it 'saves report' do
        expect { do_save_records }.to change { ::Report.count }.by(1)
      end

      it 'creates document' do
        expect { do_save_records }.to change { Document.count }.by(1)
      end

      it 'creates two documents with send_report_to_patient=true' do
        subject.send_report_to_patient = true
        expect { do_save_records }.to change { Document.count }.by(2)
      end
    end

    describe '#save_patient!' do
      let(:patient) { double(:patient) }

      before do
        allow(Patient).to receive(:find_or_create_by!).and_return(patient)
      end

      it 'finds or creates patient' do
        subject.send(:save_patient!)
        expect(Patient).to have_received(:find_or_create_by!).with(
          number:        subject.patient_number,
          first_name:    subject.patient_first_name,
          last_name:     subject.patient_last_name,
          date_of_birth: subject.patient_date_of_birth,
          sex:           subject.patient_sex,
          title:         subject.patient_title,
          suffix:        subject.patient_suffix)
      end

      it 'assigns patient' do
        subject.send(:save_patient!)
        expect(subject.patient).to eq(patient)
      end
    end

    describe '#save_address!' do
      let(:address) { double(:addres) }

      before do
        allow(Address).to receive(:find_or_create_by!).and_return(address)
      end

      it 'finds or creates address' do
        subject.send(:save_address!)
        expect(Address).to have_received(:find_or_create_by!).with(
          street: subject.recipient_street,
          zip:    subject.recipient_zip,
          city:   subject.recipient_city)
      end

      it 'assigns document' do
        subject.send(:save_address!)
        expect(subject.address).to eq(address)
      end
    end

    describe '#save_recipient!' do
      let(:address)   { double(:addres) }
      let(:recipient) { double(:recipient) }

      before do
        allow(subject).to receive(:address).and_return(address)
        allow(Recipient).to receive(:find_or_create_by!).and_return(recipient)
      end

      it 'finds or creates recipient' do
        subject.send(:save_recipient!)
        expect(Recipient).to have_received(:find_or_create_by!).with(
          first_name: subject.recipient_first_name,
          last_name:  subject.recipient_last_name,
          title:      subject.recipient_title,
          suffix:     subject.recipient_suffix,
          salutation: subject.recipient_salutation,
          fax_number: subject.recipient_fax_number,
          address:    address)
      end

      it 'assigns document' do
        subject.send(:save_recipient!)
        expect(subject.recipient).to eq(recipient)
      end
    end

    describe '#save_report!' do
      let(:user)      { double(:user) }
      let(:patient)   { double(:patient) }
      let(:report)    { double(:report) }

      before do
        allow(subject).to receive(:user).and_return(user)
        allow(subject).to receive(:patient).and_return(patient)
        allow(subject).to receive(:report).and_return(report)
        allow(report).to receive(:update!)
      end

      it 'updates report' do
        subject.send(:save_report!)
        expect(report).to have_received(:update!).with(
          patient:    patient,
          user:       user,
          study:      subject.study,
          study_date: subject.study_date,
          anamnesis:  subject.anamnesis,
          diagnosis:  subject.diagnosis,
          findings:   subject.findings,
          evaluation: subject.evaluation,
          procedure:  subject.procedure,
          clinic:     subject.clinic)
      end

      it 'assigns new report when missing'
    end

    describe '#save_document!' do
      let(:report)    { double(:report) }
      let(:recipient) { double(:recipient) }
      let(:document)  { double(:document) }

      before do
        allow(subject).to receive(:report).and_return(report)
        allow(subject).to receive(:recipient).and_return(recipient)
        allow(Document).to receive(:find_or_create_by!).and_return(document)
      end

      it 'finds or creates document' do
        subject.send(:save_document!)
        expect(Document).to have_received(:find_or_create_by!).
          with(report: report, recipient: recipient)
      end

      it 'assigns document' do
        subject.send(:save_document!)
        expect(subject.document).to eq(document)
      end
    end

    describe '#user' do
      it { should validate_presence_of(:user) }

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

    it 'saves report' do
      subject = build(:api_report)
      expect{subject.save}.to change(::Report, :count).by(1)
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

    %i(id persisted?).each do |method|
      describe "##{method}" do
        let(:report) { double('report') }
        before { allow(subject).to receive(:report).and_return(report) }

        it 'is delegated to report' do
          allow(report).to receive(method).and_return(:chunky_bacon)
          expect(subject.send(method)).to eq(:chunky_bacon)
        end
      end
    end

    describe '#send_report_to_patient' do
      it 'returns false by default' do
        expect(subject.send_report_to_patient).to be_falsey
      end

      [ nil, '', 0, '0', 'false' ].each do |value|
        it "returns false when '#{value}'" do
          subject.send_report_to_patient = value
          expect(subject.send_report_to_patient).to be_falsey
        end
      end

      [ 1, '1', 'true' ].each do |value|
        it "returns false when '#{value}'" do
          subject.send_report_to_patient = value
          expect(subject.send_report_to_patient).to be_truthy
        end
      end
    end

    describe '#save_patient_address!' do
      let(:address) { double(:addres) }

      before do
        allow(Address).to receive(:find_or_create_by!).and_return(address)
      end

      it 'finds or creates address' do
        subject.send(:save_patient_address!)
        expect(Address).to have_received(:find_or_create_by!).with(
          street: subject.patient_street,
          zip:    subject.patient_zip,
          city:   subject.patient_city)
      end

      it 'assigns patient address' do
        subject.send(:save_patient_address!)
        expect(subject.patient_address).to eq(address)
      end
    end

    describe '#save_patient_recipient!' do
      let(:address)   { double(:addres) }
      let(:recipient) { double(:recipient) }

      before do
        allow(subject).to receive(:patient_address).and_return(address)
        allow(Recipient).to receive(:find_or_create_by!).and_return(recipient)
      end

      it 'finds or creates recipient' do
        subject.send(:save_patient_recipient!)
        expect(Recipient).to have_received(:find_or_create_by!).with(
          first_name: subject.patient_first_name,
          last_name:  subject.patient_last_name,
          title:      subject.patient_title,
          suffix:     subject.patient_suffix,
          address:    address)
      end

      it 'assigns patient recipient' do
        subject.send(:save_patient_recipient!)
        expect(subject.patient_recipient).to eq(recipient)
      end
    end

    describe '#save_patient_document!' do
      let(:report)    { double(:report) }
      let(:recipient) { double(:recipient) }
      let(:document)  { double(:document) }

      before do
        allow(subject).to receive(:report).and_return(report)
        allow(subject).to receive(:patient_recipient).and_return(recipient)
        allow(Document).to receive(:find_or_create_by!).and_return(document)
      end

      it 'finds or creates document' do
        subject.send(:save_patient_document!)
        expect(Document).to have_received(:find_or_create_by!).
          with(report: report, recipient: recipient)
      end

      it 'assigns patient document' do
        subject.send(:save_patient_document!)
        expect(subject.patient_document).to eq(document)
      end
    end

    describe '#patient_sex' do
      [ 'm', 'M' ].each do |value|
        it "it male when initialized with '#{value}'" do
          subject = build(:api_report, patient_sex: value)
          patient = Patient.new(sex: subject.patient_sex)
          expect(patient).to be_male
        end
      end

      [ 'w', 'W', 'f', 'F' ].each do |value|
        it "it female when initialized with '#{value}'" do
          subject = build(:api_report, patient_sex: value)
          patient = Patient.new(sex: subject.patient_sex)
          expect(patient).to be_female
        end
      end

      [ 'u', 'U', '', nil ].each do |value|
        it "it male when initialized with '#{value}'" do
          subject = build(:api_report, patient_sex: value)
          patient = Patient.new(sex: subject.patient_sex)
          expect(patient).not_to be_male
          expect(patient).not_to be_female
        end
      end
    end
  end
end
