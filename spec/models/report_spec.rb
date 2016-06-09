describe Report do
  let(:subject) { build(:report) }

  # Associations
  [ :user, :patient, :recipient ].each do |association|
    it { expect(subject).to belong_to(association) }
  end

  it { expect(subject).to have_one(:document).dependent(:destroy) }

  it { expect(subject).to have_many(:print_jobs).through(:document) }

  it 'is translated' do
    expect(described_class.model_name.human).to eq 'Bericht'
    {
      user:       'Arzt',
      patient:    'Patient',
      recipient:  'Überweiser',
      study:      'Untersuchung',
      study_date: 'Untersuchungsdatum',
      anamnesis:  'Indikation',
      findings:   'Befund',
      evaluation: 'Beurteilung',
      procedure:  'Methode',
      clinic:     'Klinik'
    }.each do |attr,translation|
      expect(described_class.human_attribute_name(attr)).to eq translation
    end
  end

  # Required attributes
  [
    :user,
    :patient,
    :recipient,
    :anamnesis,
    :evaluation,
    :procedure,
    :study,
    :study_date
  ].each do |attribute|
    it { expect(subject).to validate_presence_of(attribute) }
  end

  # Optional attributes
  [
    :diagnosis,
    :findings,
    :clinic,
    :verified_at,
    :canceled_at
  ].each do |attribute|
    it { expect(subject).not_to validate_presence_of(attribute) }
  end

  describe '.pending' do
    it 'returns all pending reports' do
      pending = create(:pending_report)
      verified = create(:verified_report)
      canceled = create(:canceled_report)
      expect(described_class.pending.all).to eq  [ pending ]
    end
  end

  describe '.verified' do
    it 'returns all verified reports' do
      pending = create(:pending_report)
      verified = create(:verified_report)
      canceled = create(:canceled_report)
      expect(described_class.verified.all).to eq  [ verified ]
    end
  end

  describe '.canceled' do
    it 'includes only canceled reports' do
      pending = create(:pending_report)
      verified = create(:verified_report)
      canceled = create(:canceled_report)
      expect(described_class.canceled.all).to eq  [ canceled ]
    end
  end

  describe '.not_verified' do
    let(:subject) { described_class.not_verified }

    it 'includes pending report' do
      expect(subject).to include create(:pending_report)
    end

    it 'includes canceled report' do
      expect(subject).to include create(:canceled_report)
    end

    it 'excludes verified report' do
      expect(subject).not_to include create(:verified_report)
    end
  end

  describe '#status' do
    context 'when :pending' do
      let(:subject) { build(:pending_report) }

      it 'returns status as symbol' do
        expect(subject.status).to eq :pending
      end

      it 'is pending, but not verified or canceled' do
        expect(subject).to be_pending
        expect(subject).not_to be_verified
        expect(subject).not_to be_canceled
      end

      it 'has no verified_at' do
        expect(subject.verified_at).to be nil
      end

      it 'has no canceled_at' do
        expect(subject.canceled_at).to be nil
      end

      it 'can be changed to :verified' do
        subject.status = :verified
        expect(subject).to be_verified
      end

      it 'can be updated to :verified' do
        subject.save
        expect(subject.update(status: :verified)).to eq true
        expect(subject).to be_verified
      end

      it 'can not be changed to :canceled' do
        subject.status = :canceled
        expect(subject).to be_pending
      end

      it 'can not be changed to unknown status' do
        subject.status = :chunky_bacon
        expect(subject).to be_pending
      end
    end

    context 'when :verified' do
      let(:subject) { build(:verified_report) }

      it 'returns status an symbol' do
        expect(subject.status).to eq :verified
      end

      it 'is verified, but not pending or canceled' do
        expect(subject).to be_verified
        expect(subject).not_to be_pending
        expect(subject).not_to be_canceled
      end

      it 'has verified_at' do
        expect(subject.verified_at).not_to be nil
      end

      it 'has no canceled_at' do
        expect(subject.canceled_at).to be nil
      end

      it 'can be changed to :canceled' do
        subject.status = :canceled
        expect(subject).to be_canceled
      end

      it 'can be updated to :canceled' do
        subject.save
        expect(subject.update(status: :canceled)).to eq true
        expect(subject).to be_canceled
      end

      it 'can not be changed to :pending' do
        subject.status = :pending
        expect(subject).to be_verified
      end
    end

    context 'when :canceled' do
      let(:subject) { build(:canceled_report) }

      it 'returns status as symbol' do
        expect(subject.status).to eq :canceled
      end

      it 'is canceled, but not pending or canceled' do
        expect(subject).to be_canceled
        expect(subject).not_to be_verified
        expect(subject).not_to be_pending
      end

      it 'has verified_at' do
        expect(subject.verified_at).not_to be nil
      end

      it 'has canceled_at' do
        expect(subject.canceled_at).not_to be nil
      end

      it 'can not be changed to :pending' do
        subject.status = :pending
        expect(subject).to be_canceled
      end

      it 'can not be changed to :verified' do
        subject.status = :verified
        expect(subject).to be_canceled
      end
    end
  end

  describe '#report_date' do
    it 'returns report creation date' do
      allow(subject).to receive(:created_at).and_return(Time.zone.parse('2015-09-18'))
      expect(subject.report_date).to eq '18.9.2015'
    end
  end

  describe '#physician_name' do
    let(:user) { build(:user) }

    before do
      allow(user).to receive(:full_name).and_return('Dr. Gregory House')
      subject.user = user
    end

    it 'returns full recipient name' do
      expect(subject.physician_name).to eq 'Dr. Gregory House'
    end
  end


  describe '#valediction' do
    it 'returns default value' do
      expect(subject.valediction).to eq 'Mit freundlichen Grüßen'
    end
  end

  describe '#subject' do
    it 'joins study and study date' do
      subject = build(:report, study: 'MRT des Kopfes', study_date: '2016-01-01')
      expect(subject.subject).to eq 'MRT des Kopfes vom 1.1.2016'
    end
  end

  describe '#title' do
    it 'returns patient display name' do
      expect(subject.title).to eq subject.patient.display_name
    end
  end

  describe '.to_deliver' do
    let(:subject) { described_class.to_deliver }

    it 'excludes pending report' do
      report = create(:pending_report)
      expect(subject).not_to include report
    end

    it 'excludes canceled report' do
      report = create(:canceled_report)
      expect(subject).not_to include report
    end

    it 'excludes verified report with completed print job' do
      report = create(:verified_report)
      create(:completed_print_job, document: report.document)
      expect(subject).not_to include report
    end

    it 'excludes verified report with active print job' do
      report = create(:verified_report)
      create(:active_print_job, document: report.document)
      expect(subject).not_to include report
    end

    it 'includes verified report without print job' do
      report = create(:verified_report)
      expect(report.print_jobs).to be_empty
      expect(subject).to include report
    end

    it 'includes verified report with aborted print job' do
      report = create(:verified_report)
      create(:aborted_print_job, document: report.document)
      expect(subject).to include report
    end
  end

  describe '#to_deliver?' do
    it 'when pending is false' do
      subject = create(:pending_report)
      expect(subject).not_to be_to_deliver
    end

    it 'when canceled is false' do
      subject = create(:canceled_report)
      expect(subject).not_to be_to_deliver
    end

    context 'when verified' do
      let(:subject) { create(:verified_report) }

      it 'with completed print job is false' do
        create(:completed_print_job, document: subject.document)
        expect(subject).not_to be_to_deliver
      end

      it 'with active print job is false' do
        create(:active_print_job, document: subject.document)
        expect(subject).not_to be_to_deliver
      end

      it 'without print job is true' do
        expect(subject.print_jobs).to be_empty
        expect(subject).to be_to_deliver
      end

      it 'with aborted print job is true' do
        create(:aborted_print_job, document: subject.document)
        expect(subject).to be_to_deliver
      end
    end
  end

  context 'when pending' do
    let!(:subject) { create(:pending_report) }

    it 'is destroyable' do
      expect { subject.destroy }.to change(Report, :count).by(-1)
      expect(subject).to be_deletable
    end

    it 'is updatable' do
      expect(subject.update(attributes_for(:report))).to eq true
    end
  end

  %w(verified canceled).each do |status|
    context "when #{status}" do
      let!(:subject) { create("#{status}_report") }

      it 'is not destroyable' do
        expect { subject.destroy }.to change(Report, :count).by(0)
        expect(subject.errors[:base]).to be_present
        expect(subject).not_to be_deletable
      end

      it 'is not updatable' do
        expect(subject.update(attributes_for(:report))).to eq false
        expect(subject.errors[:base]).to be_present
      end
    end
  end

  describe '#deliver_as_fax' do
    context 'without fax printer' do
      it 'returns false' do
        expect(FaxPrinter.default).to be nil
        expect(subject.deliver_as_fax).to eq false
      end
    end

    context 'with fax printer' do
      before do
        Rails.application.load_seed # To make the fax printer available!
      end

      context 'but without fax number' do
        let(:recipient) { create(:recipient, fax_number: nil) }
        let(:subject) { create(:verified_report, recipient: recipient) }

        it 'returns false' do
          expect(subject.deliver_as_fax).to eq false
        end

        it 'creates no fax print job' do
          expect { subject.deliver_as_fax }.to change(PrintJob, :count).by(0)
        end
      end

      context 'and with fax number' do
        let(:recipient) { create(:recipient, fax_number: '032472384234') }
        let(:subject) { create(:verified_report, recipient: recipient) }

        it 'returns true' do
          expect(subject.deliver_as_fax).to eq true
        end

        it 'creates a fax print job' do
          expect { subject.deliver_as_fax }.to change(PrintJob, :count).by(1)
        end
      end
    end
  end

  describe '#recipient_fax_number' do
    it 'returns fax number of recipient' do
      subject.recipient.fax_number = '02342342354'
      expect(subject.recipient_fax_number).to eq '02342342354'
    end

    it 'returns nil when recipient missing' do
      subject.recipient = nil
      expect(subject.recipient_fax_number).to be nil
    end
  end

  describe '#replace_carriage_returns on save' do
    let(:text_attributes) { %i(anamnesis diagnosis findings evaluation procedure) }

    it 'converts carriage returns into new lines' do
      text_attributes.each do |text_attribute|
        subject[text_attribute] = "Text with some\r carriage\rreturns."
        subject.save
        expect(subject[text_attribute]).to eq "Text with some\n carriage\nreturns."
      end
    end

    it 'does not fail when nil' do
      text_attributes.each do |text_attribute|
        subject[text_attribute] = nil
        expect{ subject.save!(validate: false) }.not_to raise_error NoMethodError
      end
    end
  end

  describe '#patient_name' do
    let(:patient) { build(:patient) }

    before { subject.patient = patient }

    it 'returns patient display name' do
      expect(subject.patient_name).to eq patient.display_name
    end
  end

  describe '#recipient_name' do
    let(:recipient) { build(:recipient) }

    before { subject.recipient = recipient }

    it 'returns full recipient name' do
      expect(subject.recipient_name).to eq recipient.full_name
    end
  end

  describe '#recipient_address' do
    let(:recipient) { build(:recipient) }

    before { subject.recipient = recipient }

    it 'returns full recipient address' do
      expect(subject.recipient_address).to eq recipient.full_address
    end
  end

  describe '#salutation' do
    context 'when missing' do
      let(:recipient) { build(:recipient, salutation: nil) }

      before { subject.recipient = recipient }

      it 'returns default salutation' do
        expect(subject.salutation).to eq 'Sehr geehrte Kollegen,'
      end
    end

    context 'when present' do
      let(:recipient) { build(:recipient, salutation: 'Hallo Leute,') }

      before { subject.recipient = recipient }

      it 'returns recipient salutation' do
        expect(subject.salutation).to eq 'Hallo Leute,'
      end
    end
  end

  describe '#to_pdf' do
    let(:pdf) { double('ReportPdf instance') }

    before do
      allow(ReportPdf).to receive(:new).and_return(pdf)
    end

    it 'returns PDF instance' do
      expect(subject.to_pdf).to eq pdf
    end

    it 'instantiates PDF with self' do
      subject.to_pdf
      expect(ReportPdf).to have_received(:new).with(subject)
    end
  end

  describe '#signature_path' do
    let(:user) { build(:user) }

    before do
      allow(user).to receive(:signature_path).and_return('signature.png')
      subject.user = user
    end

    it 'returns path to user signature' do
      expect(subject.signature_path).to eq 'signature.png'
    end
  end

  describe '#include_signature?' do
    it 'is true with report verification' do
      subject = build(:verified_report)
      expect(subject.include_signature?).to be true
    end

    it 'is false without report verification' do
      subject = build(:pending_report)
      expect(subject.include_signature?).to be false
    end
  end

  describe 'when created' do
    let(:subject) { build(:pending_report) }

    it 'creates new document' do
      expect {
        subject.save
      }.to change(Document, :count).by(1)
      expect(subject.document).to be_present
    end

    it 'sets document title' do
      subject.save
      expect(subject.document.title).to eq subject.title
    end
  end

  describe 'when updated' do
    let!(:subject) { create(:pending_report) }

    it 'updates document when changed' do
      expect {
        subject.update(status: :verified)
      }.to change { subject.document.file_fingerprint }
    end

    it 'does not update document when nothing has changed' do
      expect {
        subject.save
      }.not_to change { subject.document.file_fingerprint }
    end
  end
end
