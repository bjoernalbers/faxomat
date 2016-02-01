describe Report do
  let(:report) { build(:report) }

  # Associations
  [ :user, :patient, :recipient ].each do |association|
    it { expect(report).to belong_to(association) }
  end

  it { expect(report).to have_many(:faxes) }

  it { expect(report).to have_one(:letter) }

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

      context 'and changed to :verified' do
        before do
          report.status = :verified
        end

        it 'is valid' do
          expect(report).to be_valid
        end

        it 'sets verified_at on save once' do
          now = Time.zone.now

          Timecop.freeze(now) { report.save }
          expect(report.verified_at).to eq now

          Timecop.freeze(now+1.week) { report.save }
          expect(report.verified_at).to eq now
        end
      end

      context 'and changed to :canceled' do
        before do
          report.status = :canceled
        end

        it 'is invalid' do
          expect(report).to be_invalid
          expect(report.errors[:status]).to be_present
        end
      end

      context 'and changed to "verified"' do
        before do
          report.status = "verified"
        end

        it 'returns status as symbol' do
          expect(report.status).to eq :verified
        end
      end

      context 'and changed to nil' do
        before do
          report.status = nil
        end

        it 'is :pending' do
          expect(report.status).to eq :pending
        end
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

      context 'and changed to :pending' do
        before do
          report.status = :pending
        end

        it 'is invalid' do
          expect(report).to be_invalid
          expect(report.errors[:status]).to be_present
        end
      end

      context 'and changed to :canceled' do
        before do
          report.status = :canceled
        end

        it 'is valid' do
          expect(report).to be_valid
        end

        it 'sets canceled_at on save once' do
          now = Time.zone.now

          Timecop.freeze(now) { report.save }
          expect(report.canceled_at).to eq now

          Timecop.freeze(now+1.week) { report.save }
          expect(report.canceled_at).to eq now
        end
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

      context 'and changed to :pending' do
        before do
          report.status = :pending
        end

        it 'is invalid' do
          expect(report).to be_invalid
          expect(report.errors[:status]).to be_present
        end
      end

      context 'and changed to :verified' do
        before do
          report.status = :verified
        end

        it 'is invalid' do
          expect(report).to be_invalid
          expect(report.errors[:status]).to be_present
        end
      end
    end

    context 'with unknown status' do
      before do
        report.status = :chunky_bacon
      end

      it 'is invalid' do
        expect(report).to be_invalid
        expect(report.errors[:status]).to be_present
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

  describe '.not_delivered' do
    it 'excludes pending reports' do
      report = create(:pending_report)
      expect(Report.not_delivered).not_to include report
    end

    it 'excludes canceled reports' do
      report = create(:canceled_report)
      expect(Report.not_delivered).not_to include report
    end

    it 'excludes verified reports with letter' do
      report = create(:verified_report)
      create(:letter, report: report)
      expect(Report.not_delivered).not_to include report
    end

    it 'includes verified reports with active fax' do
      report = create(:verified_report)
      create(:active_fax, report: report)
      expect(Report.not_delivered).to include report
    end

    it 'includes verified reports with aborted fax' do
      report = create(:verified_report)
      create(:aborted_fax, report: report)
      expect(Report.not_delivered).to include report
    end

    it 'excludes reports with completed fax' do
      report = create(:verified_report)
      create(:completed_fax, report: report)
      expect(Report.not_delivered).not_to include report
    end
  end

  describe '#delivered?' do
    let(:report) { create(:verified_report) }

    context 'without letter' do
      it 'and without fax is false' do
        expect(report.faxes).to be_empty
        expect(report).not_to be_delivered
      end

      it 'and without completed fax is false' do
        create(:active_fax, report: report)
        create(:aborted_fax, report: report)
        expect(report).not_to be_delivered
      end

      it 'and completed fax is true' do
        create(:completed_fax, report: report)
        expect(report).to be_delivered
      end
    end

    context 'with letter' do
      before do
        create(:letter, report: report)
      end

      it 'is true' do
        expect(report).to be_delivered
      end
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

  describe '#deliver_as_fax' do
    it 'delivers itself as fax' do
      allow(ReportFaxer).to receive(:deliver)
      report.deliver_as_fax
      expect(ReportFaxer).to have_received(:deliver).with(report)
    end
  end
end
