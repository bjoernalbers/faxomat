describe Report do
  let(:subject) { build(:report) }

  # Associations
  [ :user, :patient ].each do |association|
    it { expect(subject).to belong_to(association) }
  end

  it { expect(subject).to have_many(:documents).dependent(:destroy) }

  it { expect(subject).to have_many(:prints).through(:documents) }

  it { expect(subject).to have_one(:release) }

  it { expect(subject).to have_many(:signings) }

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
      clinic:     'Klinik'
    }.each do |attr,translation|
      expect(described_class.human_attribute_name(attr)).to eq translation
    end
  end

  # Required attributes
  [
    :user,
    :patient,
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

  describe '.unreleased reports' do
    it 'returns all pending and signed reports' do
      pending = create(:pending_report)
      pending_and_signed = create(:pending_report, user: create(:unauthorized_user))
      pending_and_signed.verify!
      verified = create(:verified_report)
      canceled = create(:canceled_report)
      expect(described_class.unreleased.all).to eq  [ pending_and_signed ]
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
      let(:subject) { create(:pending_report) }

      it 'returns status as symbol' do
        expect(subject.status).to eq :pending
      end

      it 'is pending, but not verified or canceled' do
        expect(subject).to be_pending
        expect(subject).not_to be_verified
        expect(subject).not_to be_canceled
      end

      it 'is verifiable' do
        subject.verify!
        expect(subject).to be_verified
      end

      it 'is not cancelable' do
        subject.cancel!
        expect(subject).to be_pending
      end
    end

    context 'when :verified' do
      let(:subject) { create(:verified_report) }

      it 'returns status an symbol' do
        expect(subject.status).to eq :verified
      end

      it 'is verified, but not pending or canceled' do
        expect(subject).to be_verified
        expect(subject).not_to be_pending
        expect(subject).not_to be_canceled
      end

      it 'is cancelable' do
        subject.cancel!
        expect(subject).to be_canceled
      end
    end

    context 'when :canceled' do
      let(:subject) { create(:canceled_report) }

      it 'returns status as symbol' do
        expect(subject.status).to eq :canceled
      end

      it 'is canceled, but not pending or canceled' do
        expect(subject).to be_canceled
        expect(subject).not_to be_verified
        expect(subject).not_to be_pending
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

    it 'returns full user name' do
      expect(subject.physician_name).to eq 'Dr. Gregory House'
    end
  end

  describe '#physician_suffix' do
    let(:user) { build(:user, suffix: 'Chunky Bacon') }

    before do
      subject.user = user
    end

    it 'returns full user suffix' do
      expect(subject.physician_suffix).to eq 'Chunky Bacon'
    end
  end


  describe '#valediction' do
    it 'returns default value' do
      expect(subject.valediction).to eq 'Mit freundlichen Grüßen'
    end
  end

  describe '#subject' do
    it 'joins study and study date' do
      subject = build(:report, study: 'MRT des Kopfes', study_date: '2016-01-01 02:34')
      expect(subject.subject).to eq 'MRT des Kopfes vom 1.1.2016 um 02:34 Uhr'
    end
  end

  describe '#title' do
    it 'returns patient display name' do
      expect(subject.title).to eq subject.patient.display_name
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

  context 'when signed' do
    subject { create(:report) }

    before do
      create(:report_signing, report: subject)
    end

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
        expect{ subject.save!(validate: false) }.not_to raise_error
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

  describe '#include_signature?' do
    it 'is true with report release' do
      subject = create(:verified_report)
      expect(subject.include_signature?).to be true
    end

    it 'is false without report release' do
      subject = build(:pending_report)
      expect(subject.include_signature?).to be false
    end
  end

  describe '#signed?' do
    subject { create(:report) }

    it 'is true when signed' do
      create(:report_signing, report: subject)
      expect(subject).to be_signed
    end

    it 'is false when not signed' do
      expect(subject).not_to be_signed
    end
  end

  describe '#signed_by?' do
    subject { create(:report) }
    let!(:signing) { create(:report_signing, report: subject) }

    it 'is true when signed by user' do
      expect(subject).to be_signed_by(signing.user)
    end

    it 'is false when signed by other user' do
      other = create(:user)
      expect(subject).not_to be_signed_by(other)
    end
  end

  describe 'on verification' do
    let!(:subject) { create(:pending_report) }
    let!(:document) { create(:document, report: subject) }

    it 'updates documents' do
      old_fingerprint = document.fingerprint
      subject.verify!
      document.reload
      expect(document.fingerprint).not_to eq(old_fingerprint)
    end
  end

  describe 'on cancelation' do
    let!(:subject) { create(:verified_report) }
    let!(:document) { create(:document, report: subject) }

    it 'updates documents' do
      old_fingerprint = document.fingerprint
      subject.cancel!
      document.reload
      expect(document.fingerprint).not_to eq(old_fingerprint)
    end
  end

  describe '#cancelable_by?' do
    let(:user) { create(:user) }

    it 'is false when not verified' do
      subject = create(:pending_report, user: user)
      expect(subject).not_to be_cancelable_by(user)
    end

    it 'is false when verified but from other user' do
      subject = create(:verified_report, user: create(:user))
      expect(subject).not_to be_cancelable_by(user)
    end

    it 'is true when verified and from user' do
      subject = create(:verified_report, user: user)
      expect(subject).to be_cancelable_by(user)
    end
  end
end
