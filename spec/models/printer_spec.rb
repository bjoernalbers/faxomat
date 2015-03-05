require 'spec_helper'

RSpec.describe Printer, :type => :model do
  let(:fax) { create(:fax) }
  let(:printer) { Printer.new(fax) }

  describe '#printer_name' do
    it 'defaults to "Fax"' do
      expect(printer.printer_name).to eq 'Fax'
    end
  end

  describe '#dialout_prefix' do
    it 'defaults to 0' do
      expect(printer.dialout_prefix).to eq 0
    end
  end

  describe '#print' do
    let(:cups_print_job) { double('cups_print_job') }

    before do
      allow(Cups::PrintJob).to receive(:new).and_return(cups_print_job)

      allow(cups_print_job).to receive(:title=)
      allow(cups_print_job).to receive(:print) { true }
      allow(cups_print_job).to receive(:job_id) { 42 }

      allow(fax).to receive(:path).and_return('chunky_bacon.pdf')
      allow(fax).to receive(:phone).and_return('012456789')
    end

    it 'prints fax on CUPS fax printer' do
      printer.print
      expect(Cups::PrintJob).to have_received(:new).
        with(fax.path, printer.printer_name, {'phone' => '0'+fax.phone})
      expect(cups_print_job).to have_received(:print)
    end

    it 'sets print job title' do
      printer.print
      expect(cups_print_job).to have_received(:title=).with(fax.title)
    end

    context 'when printed successfully' do
      before do
        allow(cups_print_job).to receive(:print).and_return(true)
      end

      it 'creates print job with CUPS jobs id' do
        expect {
          printer.print
        }.to change(fax.print_jobs, :count).by(1)
        print_job = fax.print_jobs.find_by(cups_id: cups_print_job.job_id)
        expect(print_job).not_to be nil
      end
    end

    context 'when not printed successfully' do
      before do
        allow(cups_print_job).to receive(:print).and_return(false)
      end

      it 'creates no print job' do
        expect{ printer.print }.to raise_error
        expect(fax.print_jobs).to be_empty
      end
    end
  end
end
