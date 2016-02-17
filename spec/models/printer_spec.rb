describe Printer do
  let(:printer) { Printer.new(printer_name: 'Fax') }

  describe '#print' do
    let(:fax) { build(:fax) }
    let(:cups_job) { double('cups_job') }

    before do
      allow(Cups::PrintJob).to receive(:new).and_return(cups_job)

      allow(cups_job).to receive(:title=)
      allow(cups_job).to receive(:print) { true }
      allow(cups_job).to receive(:job_id) { 42 }

      allow(fax).to receive(:path).and_return('chunky_bacon.pdf')
      allow(fax).to receive(:phone).and_return('012456789')
    end

    it 'prints fax on CUPS fax printer' do
      printer = Printer.new(dialout_prefix: 0)
      printer.print(fax)
      expect(Cups::PrintJob).to have_received(:new).
        with(fax.path, printer.printer_name, {'phone' => '0' + fax.phone})
      expect(cups_job).to have_received(:print)
    end

    it 'sets print job title' do
      printer.print(fax)
      expect(cups_job).to have_received(:title=).with(fax.title)
    end

    context 'when printed successfully' do
      before do
        allow(cups_job).to receive(:print).and_return(true)
      end

      it 'returns CUPS job ID' do
        expect(printer.print(fax)).to eq cups_job.job_id
      end
    end

    context 'when not printed successfully' do
      before do
        allow(cups_job).to receive(:print).and_return(false)
      end

      it 'returns false' do
        expect(printer.print(fax)).to be false
      end
    end
  end

  describe '#check' do
    let(:fax) { build(:fax) }

    before do
      allow(printer).to receive(:cups_job_statuses) { { } }
    end

    it 'updates cups_job_status of print jobs' do
      allow(printer).to receive(:cups_job_statuses).and_return(
        { fax.cups_job_id => 'completed' }
      )
      printer.check [fax]
      expect(fax).to be_completed
    end

    it 'calls cups_job_status only once' do
      printer.check [fax, fax]
      expect(printer).to have_received(:cups_job_statuses).once
    end
  end

  describe '#dialout_prefix' do
    context 'with option :dialout_prefix' do
      let(:printer) { Printer.new(dialout_prefix: 7) }

      it 'assigns from option' do
        expect(printer.dialout_prefix).to eq 7
      end
    end

    context 'without option :dialout_prefix' do
      let(:printer) { Printer.new }

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
      let(:printer) { Printer.new(printer_name: 'Chunky') }

      it 'assigns from option' do
        expect(printer.printer_name).to eq 'Chunky'
      end
    end

    context 'without option :printer_name' do
      let(:printer) { Printer.new }

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
