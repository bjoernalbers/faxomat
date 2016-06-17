describe Report::Printing do
  let(:report) { create(:verified_report) }
  let(:printer) { create(:printer) }
  let(:printing) { Report::Printing.new(report: report, printer: printer) }

  it 'has valid factory' do
    expect(printing).to be_valid
  end

  it { expect(printing).to validate_presence_of(:report) }

  it { expect(printing).to validate_presence_of(:printer) }
  
  describe '#report_id=' do
    it 'assigns report when report exists' do
      printing.report_id = report.id
      expect(printing.report).to eq report
    end

    it 'assigns nil when report does not exist' do
      printing.report_id = 234245345345
      expect(printing.report).to be nil
    end
  end

  describe '#report_id' do
    it 'returns report id when report exists' do
      printing.report = report
      expect(printing.report_id).to eq report.id
    end

    it 'returns nil when report does not exist' do
      printing.report = nil
      expect(printing.report_id).to be nil
    end
  end

  describe '#printer_id=' do
    it 'assigns printer when printer exists' do
      printing.printer_id = printer.id
      expect(printing.printer).to eq printer
    end

    it 'assigns nil when printer does not exist' do
      printing.printer_id = 234245345345
      expect(printing.printer).to be nil
    end
  end

  describe '#printer_id' do
    it 'returns printer id when printer exists' do
      printing.printer = printer
      expect(printing.printer_id).to eq printer.id
    end

    it 'returns nil when printer does not exist' do
      printing.printer = nil
      expect(printing.printer_id).to be nil
    end
  end

  context 'with verified report' do
    let(:report) { create(:verified_report) }

    it 'is valid' do
      expect(printing).to be_valid
    end
  end

  context 'without verified report' do
    let(:report) { create(:pending_report) }

    it 'is invalid' do
      expect(printing).to be_invalid
      expect(printing.errors[:report]).to be_present
    end
  end

  describe '#save' do
    context 'when valid' do
      it 'creates print_job' do
        expect {
          printing.save
        }.to change(PrintJob, :count).by(1)
      end

      it 'builds print job with report attributes' do
        printing.save
        print_job = printing.print_job
        expect(print_job.printer).to eq printing.printer
        expect(print_job.title).to eq report.title
        expect(print_job.fax_number).to eq report.recipient_fax_number
        expect(print_job.document).to eq report.document
      end

      it 'returns true' do
        expect(printing.save).to be true
      end
    end

    context 'when invalid' do
      let(:printing) { Report::Printing.new }

      it 'does not create print_job' do
        expect {
          printing.save
        }.to change(PrintJob, :count).by(0)
      end

      it 'returns false' do
        expect(printing.save).to be false
      end

      it 'does not assign print job' do
        printing.save
        expect(printing.print_job).to be nil
      end
    end
  end
end
