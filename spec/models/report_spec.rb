describe Report do
  let(:report) { build(:report) }

  # Associations
  [ :user, :patient, :recipient ].each do |association|
    it { expect(report).to belong_to(association) }
  end

  it { expect(report).to have_many(:print_jobs) }

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
    it { expect(report).to validate_presence_of(attribute) }
  end

  # Optional attributes
  [
    :diagnosis,
    :findings,
    :clinic,
    :verified_at,
    :canceled_at
  ].each do |attribute|
    it { expect(report).not_to validate_presence_of(attribute) }
  end

  describe '.pending' do
    let(:now) { Time.zone.now }

    it 'returns all pending reports' do
      pending = create(:pending_report)
      verified = create(:verified_report)
      canceled = create(:canceled_report)
      expect(Report.pending.all).to eq  [ pending ]
    end
  end

  describe '.verified' do
    let(:now) { Time.zone.now }

    it 'returns all verified reports' do
      pending = create(:pending_report)
      verified = create(:verified_report)
      canceled = create(:canceled_report)
      expect(Report.verified.all).to eq  [ verified ]
    end
  end

  describe '#status' do
    context 'when :pending' do
      let(:report) { build(:pending_report) }

      it 'returns status as symbol' do
        expect(report.status).to eq :pending
      end

      it 'is pending, but not verified or canceled' do
        expect(report).to be_pending
        expect(report).not_to be_verified
        expect(report).not_to be_canceled
      end

      it 'has no verified_at' do
        expect(report.verified_at).to be nil
      end

      it 'has no canceled_at' do
        expect(report.canceled_at).to be nil
      end

      it 'can be changed to :verified' do
        report.status = :verified
        expect(report).to be_verified
      end

      it 'can be updated to :verified' do
        report.save
        expect(report.update(status: :verified)).to eq true
        expect(report).to be_verified
      end

      it 'can not be changed to :canceled' do
        report.status = :canceled
        expect(report).to be_pending
      end

      it 'can not be changed to unknown status' do
        report.status = :chunky_bacon
        expect(report).to be_pending
      end
    end

    context 'when :verified' do
      let(:report) { build(:verified_report) }

      it 'returns status an symbol' do
        expect(report.status).to eq :verified
      end

      it 'is verified, but not pending or canceled' do
        expect(report).to be_verified
        expect(report).not_to be_pending
        expect(report).not_to be_canceled
      end

      it 'has verified_at' do
        expect(report.verified_at).not_to be nil
      end

      it 'has no canceled_at' do
        expect(report.canceled_at).to be nil
      end

      it 'can be changed to :canceled' do
        report.status = :canceled
        expect(report).to be_canceled
      end

      it 'can be updated to :canceled' do
        report.save
        expect(report.update(status: :canceled)).to eq true
        expect(report).to be_canceled
      end

      it 'can not be changed to :pending' do
        report.status = :pending
        expect(report).to be_verified
      end
    end

    context 'when :canceled' do
      let(:report) { build(:canceled_report) }

      it 'returns status as symbol' do
        expect(report.status).to eq :canceled
      end

      it 'is canceled, but not pending or canceled' do
        expect(report).to be_canceled
        expect(report).not_to be_verified
        expect(report).not_to be_pending
      end

      it 'has verified_at' do
        expect(report.verified_at).not_to be nil
      end

      it 'has canceled_at' do
        expect(report.canceled_at).not_to be nil
      end

      it 'can not be changed to :pending' do
        report.status = :pending
        expect(report).to be_canceled
      end

      it 'can not be changed to :verified' do
        report.status = :verified
        expect(report).to be_canceled
      end
    end
  end

  describe '#subject' do
    it 'joins study and study date' do
      report = build(:report, study: 'MRT des Kopfes', study_date: '2016-01-01')
      expect(report.subject).to eq 'MRT des Kopfes vom 1.1.2016'
    end
  end

  describe '#title' do
    it 'returns patient display name' do
      expect(report.title).to eq report.patient.display_name
    end
  end

  describe '.undelivered' do
    it 'excludes pending reports' do
      report = create(:pending_report)
      expect(Report.undelivered).not_to include report
    end

    it 'excludes canceled reports' do
      report = create(:canceled_report)
      expect(Report.undelivered).not_to include report
    end

    it 'excludes verified reports with active print_job' do
      report = create(:verified_report)
      create(:active_print_job, report: report)
      expect(Report.undelivered).not_to include report
    end

    it 'includes verified reports with aborted print_job' do
      report = create(:verified_report)
      create(:aborted_print_job, report: report)
      expect(Report.undelivered).to include report
    end

    it 'excludes reports with completed print_job' do
      report = create(:verified_report)
      create(:completed_print_job, report: report)
      expect(Report.undelivered).not_to include report
    end
  end

  describe '#undelivered?' do
    let(:report) { create(:verified_report) }

    it 'without print_job is true' do
      expect(report.print_jobs).to be_empty
      expect(report).to be_undelivered
    end

    it 'with aborted print job is true' do
      create(:aborted_print_job, report: report)
      expect(report).to be_undelivered
    end

    it 'with active print_job is false' do
      create(:active_print_job, report: report)
      expect(report).not_to be_undelivered
    end

    it 'with completed print_job is false' do
      create(:completed_print_job, report: report)
      expect(report).not_to be_undelivered
    end
  end

  context 'when pending' do
    let!(:report) { create(:pending_report) }

    it 'is destroyable' do
      expect { report.destroy }.to change(Report, :count).by(-1)
      expect(report).to be_deletable
    end

    it 'is updatable' do
      expect(report.update(attributes_for(:report))).to eq true
    end
  end

  %w(verified canceled).each do |status|
    context "when #{status}" do
      let!(:report) { create("#{status}_report") }

      it 'is not destroyable' do
        expect { report.destroy }.to change(Report, :count).by(0)
        expect(report.errors[:base]).to be_present
        expect(report).not_to be_deletable
      end

      it 'is not updatable' do
        expect(report.update(attributes_for(:report))).to eq false
        expect(report.errors[:base]).to be_present
      end
    end
  end

  describe '#deliver_as_fax' do
    context 'without fax printer' do
      it 'returns false' do
        expect(FaxPrinter.default).to be nil
        expect(report.deliver_as_fax).to eq false
      end
    end

    context 'with fax printer' do
      before do
        Rails.application.load_seed # To make the fax printer available!
      end

      context 'but without fax number' do
        let(:recipient) { create(:recipient, fax_number: nil) }
        let(:report) { create(:verified_report, recipient: recipient) }

        it 'returns false' do
          expect(report.deliver_as_fax).to eq false
        end

        it 'creates no fax print job' do
          expect { report.deliver_as_fax }.to change(PrintJob, :count).by(0)
        end
      end

      context 'and with fax number' do
        let(:recipient) { create(:recipient, fax_number: '032472384234') }
        let(:report) { create(:verified_report, recipient: recipient) }

        it 'returns true' do
          expect(report.deliver_as_fax).to eq true
        end

        it 'creates a fax print job' do
          expect { report.deliver_as_fax }.to change(PrintJob, :count).by(1)
        end
      end
    end
  end

  describe '#recipient_fax_number' do
    it 'returns fax number of recipient' do
      report.recipient.fax_number = '02342342354'
      expect(report.recipient_fax_number).to eq '02342342354'
    end

    it 'returns nil when recipient missing' do
      report.recipient = nil
      expect(report.recipient_fax_number).to be nil
    end
  end

  describe '#replace_carriage_returns on save' do
    let(:text_attributes) { %i(anamnesis diagnosis findings evaluation procedure) }

    it 'converts carriage returns into new lines' do
      text_attributes.each do |text_attribute|
        report[text_attribute] = "Text with some\r carriage\rreturns."
        report.save
        expect(report[text_attribute]).to eq "Text with some\n carriage\nreturns."
      end
    end

    it 'does not fail when nil' do
      text_attributes.each do |text_attribute|
        report[text_attribute] = nil
        expect{ report.save!(validate: false) }.not_to raise_error NoMethodError
      end
    end
  end
end
