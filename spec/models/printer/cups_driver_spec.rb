describe Printer::CupsDriver do
  let(:printer) { build(:printer, name: 'ChunkyPrinter', dialout_prefix: 6) }
  let(:driver) { Printer::CupsDriver.new(printer) }

  describe '#print' do
    let(:print_job) { build(:print_job) }
    let(:cups_job) { double('cups_job') }

    before do
      allow(Cups::PrintJob).to receive(:new).and_return(cups_job)

      allow(cups_job).to receive(:title=)
      allow(cups_job).to receive(:print) { true }
      allow(cups_job).to receive(:job_id) { 42 }

      allow(print_job).to receive(:path).and_return('chunky_bacon.pdf')
      allow(print_job).to receive(:fax_number).and_return('012456789')
    end

    context 'with fax printer' do
      before do
        printer.is_fax_printer = true
      end

      it 'prints as CUPS fax print_job' do
        driver.print(print_job)
        expect(Cups::PrintJob).to have_received(:new).
          with('chunky_bacon.pdf', 'ChunkyPrinter', {'phone' => '6012456789'})
        expect(cups_job).to have_received(:print)
      end
    end

    context 'without fax printer' do
      before do
        printer.is_fax_printer = false
      end

      it 'prints as CUPS print_job' do
        driver.print(print_job)
        expect(Cups::PrintJob).to have_received(:new).
          with('chunky_bacon.pdf', 'ChunkyPrinter')
        expect(cups_job).to have_received(:print)
      end
    end

    it 'sets print job title' do
      driver.print(print_job)
      expect(cups_job).to have_received(:title=).with(print_job.title)
    end

    context 'when printed successfully' do
      before do
        allow(cups_job).to receive(:print).and_return(true)
      end

      it 'returns CUPS job ID' do
        expect(driver.print(print_job)).to eq cups_job.job_id
      end
    end

    context 'when not printed successfully' do
      before do
        allow(cups_job).to receive(:print).and_return(false)
      end

      it 'returns false' do
        expect(driver.print(print_job)).to be false
      end
    end
  end

  describe '#check' do
    let(:print_job) { build(:print_job) }

    before do
      allow(driver).to receive(:cups_job_statuses) { { } }
    end

    it 'calls cups_job_status only once' do
      driver.check [print_job, print_job]
      expect(driver).to have_received(:cups_job_statuses).once
    end

    context 'when cups returns "completed"' do
      before do
        allow(driver).to receive(:cups_job_statuses).and_return(
          { print_job.cups_job_id => 'completed' }
        )
      end

      it 'sets print_job status to "completed"' do
        driver.check [print_job]
        expect(print_job).to be_completed
      end
    end

    context 'when cups returns "aborted"' do
      before do
        allow(driver).to receive(:cups_job_statuses).and_return(
          { print_job.cups_job_id => 'aborted' }
        )
      end

      it 'sets print_job status to "aborted"' do
        driver.check [print_job]
        expect(print_job).to be_aborted
      end
    end

    context 'when cups returns "cancelled"' do
      before do
        allow(driver).to receive(:cups_job_statuses).and_return(
          { print_job.cups_job_id => 'cancelled' }
        )
      end

      it 'sets print_job status to "aborted"' do
        driver.check [print_job]
        expect(print_job).to be_aborted
      end
    end

    context 'when cups returns no status' do
      before do
        allow(driver).to receive(:cups_job_statuses).and_return(
          { }
        )
      end

      it 'sets print_job status to "active"' do
        driver.check [print_job]
        expect(print_job).to be_active
      end
    end
  end

  describe '#cups_job_statuses' do
    before do
      allow(Cups).to receive(:all_jobs).and_return( {} )
    end

    it 'queries statuses from CUPS' do
      driver.send(:cups_job_statuses)
      expect(Cups).to have_received(:all_jobs).with('ChunkyPrinter')
    end

    it 'returns CUPS status by id' do
      allow(Cups).to receive(:all_jobs).and_return(
        { 1 => {state: :chunky}, 2 => {state: :bacon} }
      )
      expect(driver.send(:cups_job_statuses)).to eq(
        { 1 => 'chunky', 2 => 'bacon' }
      )
    end
  end
end
