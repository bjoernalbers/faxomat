describe Report do
  let(:report) { build(:report) }

  # Associations
  [ :user, :patient, :recipient ].each do |association|
    it { expect(report).to belong_to(association) }
  end

  it { expect(report).to have_many(:print_jobs) }

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

  describe '.unsent' do
    it 'excludes pending reports' do
      report = create(:pending_report)
      expect(Report.unsent).not_to include report
    end

    it 'excludes canceled reports' do
      report = create(:canceled_report)
      expect(Report.unsent).not_to include report
    end

    it 'includes verified reports with active print_job' do
      report = create(:verified_report)
      create(:active_print_job, report: report)
      expect(Report.unsent).to include report
    end

    it 'includes verified reports with aborted print_job' do
      report = create(:verified_report)
      create(:aborted_print_job, report: report)
      expect(Report.unsent).to include report
    end

    it 'excludes reports with completed print_job' do
      report = create(:verified_report)
      create(:completed_print_job, report: report)
      expect(Report.unsent).not_to include report
    end
  end

  describe '#sent?' do
    let(:report) { create(:verified_report) }

    it 'without print_job is false' do
      expect(report.print_jobs).to be_empty
      expect(report).not_to be_sent
    end

    it 'without completed print_job is false' do
      create(:active_print_job, report: report)
      create(:aborted_print_job, report: report)
      expect(report).not_to be_sent
    end

    it 'with completed print_job is true' do
      create(:completed_print_job, report: report)
      expect(report).to be_sent
    end
  end

  describe '#destroy' do
    context 'when pending' do
      let!(:report) { create(:pending_report) }

      it 'destroys report' do
        expect {
          report.destroy
        }.to change(Report, :count).by(-1)
      end
    end

    %w(verified canceled).each do |status|
      context "when #{status}" do
        let!(:report) { create("#{status}_report") }

        it 'does not destroy report' do
          expect {
            report.destroy
          }.to change(Report, :count).by(0)
        end

        it 'adds error to base' do
          report.destroy
          expect(report.errors[:base]).to be_present
        end
      end
    end
  end

  describe '#deletable?' do
    it 'is true when pending' do
      expect(build(:pending_report)).to be_deletable
    end

    it 'is false when verified' do
      expect(build(:verified_report)).not_to be_deletable
    end

    it 'is false when canceled' do
      expect(build(:canceled_report)).not_to be_deletable
    end
  end

  describe '#deliver_as_print_job' do
    it 'delivers itself as print_job' do
      allow(ReportFaxer).to receive(:deliver)
      report.deliver_as_fax
      expect(ReportFaxer).to have_received(:deliver).with(report)
    end
  end
end
