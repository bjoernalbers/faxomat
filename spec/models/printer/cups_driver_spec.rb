describe Printer::CupsDriver do
  let(:printer) { Printer::CupsDriver.new(printer_name: 'Fax') }

  describe '#print' do
    let(:print_job) { build(:print_job) }
    let(:cups_job) { double('cups_job') }

    before do
      allow(Cups::PrintJob).to receive(:new).and_return(cups_job)

      allow(cups_job).to receive(:title=)
      allow(cups_job).to receive(:print) { true }
      allow(cups_job).to receive(:job_id) { 42 }

      allow(print_job).to receive(:path).and_return('chunky_bacon.pdf')
      allow(print_job).to receive(:phone).and_return('012456789')
    end

    it 'prints print_job on CUPS print_job printer' do
      printer = Printer::CupsDriver.new(dialout_prefix: 0)
      printer.print(print_job)
      expect(Cups::PrintJob).to have_received(:new).
        with(print_job.path, printer.printer_name, {'phone' => '0' + print_job.phone})
      expect(cups_job).to have_received(:print)
    end

    it 'sets print job title' do
      printer.print(print_job)
      expect(cups_job).to have_received(:title=).with(print_job.title)
    end

    context 'when printed successfully' do
      before do
        allow(cups_job).to receive(:print).and_return(true)
      end

      it 'returns CUPS job ID' do
        expect(printer.print(print_job)).to eq cups_job.job_id
      end
    end

    context 'when not printed successfully' do
      before do
        allow(cups_job).to receive(:print).and_return(false)
      end

      it 'returns false' do
        expect(printer.print(print_job)).to be false
      end
    end
  end

  describe '#check' do
    let(:print_job) { build(:print_job) }

    before do
      allow(printer).to receive(:cups_job_statuses) { { } }
    end

    it 'calls cups_job_status only once' do
      printer.check [print_job, print_job]
      expect(printer).to have_received(:cups_job_statuses).once
    end

    context 'when cups returns "completed"' do
      before do
        allow(printer).to receive(:cups_job_statuses).and_return(
          { print_job.cups_job_id => 'completed' }
        )
      end

      it 'sets print_job status to "completed"' do
        printer.check [print_job]
        expect(print_job).to be_completed
      end
    end

    context 'when cups returns "aborted"' do
      before do
        allow(printer).to receive(:cups_job_statuses).and_return(
          { print_job.cups_job_id => 'aborted' }
        )
      end

      it 'sets print_job status to "aborted"' do
        printer.check [print_job]
        expect(print_job).to be_aborted
      end
    end

    context 'when cups returns "cancelled"' do
      before do
        allow(printer).to receive(:cups_job_statuses).and_return(
          { print_job.cups_job_id => 'cancelled' }
        )
      end

      it 'sets print_job status to "aborted"' do
        printer.check [print_job]
        expect(print_job).to be_aborted
      end
    end

    context 'when cups returns no status' do
      before do
        allow(printer).to receive(:cups_job_statuses).and_return(
          { }
        )
      end

      it 'sets print_job status to "active"' do
        printer.check [print_job]
        expect(print_job).to be_active
      end
    end
  end

  describe '#dialout_prefix' do
    context 'with option :dialout_prefix' do
      let(:printer) { Printer::CupsDriver.new(dialout_prefix: 7) }

      it 'assigns from option' do
        expect(printer.dialout_prefix).to eq 7
      end
    end

    context 'without option :dialout_prefix' do
      let(:printer) { Printer::CupsDriver.new }

      before do
        allow(ENV).to receive(:fetch).and_return(8)
      end

      it 'assigns from environment' do
        expect(printer.dialout_prefix).to eq 8
      end

      it 'fetches ENV["DIALOUT_PREFIX"] with default' do
        printer.dialout_prefix
        expect(ENV).to have_received(:fetch).with('DIALOUT_PREFIX', nil)
      end
    end
  end

  describe '#printer_name' do
    context 'with option :printer_name' do
      let(:printer) { Printer::CupsDriver.new(printer_name: 'Chunky') }

      it 'assigns from option' do
        expect(printer.printer_name).to eq 'Chunky'
      end
    end

    context 'without option :printer_name' do
      let(:printer) { Printer::CupsDriver.new }

      before do
        allow(ENV).to receive(:fetch).and_return('Bacon')
      end

      it 'assigns from environment' do
        expect(printer.printer_name).to eq 'Bacon'
      end

      it 'fetches ENV["PRINTER_NAME"] with default' do
        printer.printer_name
        expect(ENV).to have_received(:fetch).with('PRINTER_NAME', 'Fax')
      end
    end
  end

  describe '#cups_job_statuses' do
    before do
      allow(Cups).to receive(:all_jobs).and_return( {} )
    end

    it 'queries statuses from CUPS' do
      printer.send(:cups_job_statuses)
      expect(Cups).to have_received(:all_jobs).with('Fax')
    end

    it 'returns CUPS status by id' do
      allow(Cups).to receive(:all_jobs).and_return(
        { 1 => {state: :chunky}, 2 => {state: :bacon} }
      )
      expect(printer.send(:cups_job_statuses)).to eq(
        { 1 => 'chunky', 2 => 'bacon' }
      )
    end
  end
end
