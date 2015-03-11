require 'spec_helper'

RSpec.describe Printer, :type => :model do
  let(:printer) { Printer.new }

  describe '#print' do
    let(:fax) { create(:fax) }
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
      allow(printer).to receive(:dialout_prefix).and_return('5')
      printer.print(fax)
      expect(Cups::PrintJob).to have_received(:new).
        with(fax.path, printer.printer_name, {'phone' => '5'+fax.phone})
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

      it 'creates print job with CUPS jobs id' do
        expect {
          printer.print(fax)
        }.to change(fax.print_jobs, :count).by(1)
        print_job = fax.print_jobs.find_by(cups_job_id: cups_job.job_id)
        expect(print_job).not_to be nil
      end
    end

    context 'when not printed successfully' do
      before do
        allow(cups_job).to receive(:print).and_return(false)
      end

      it 'creates no print job' do
        expect{ printer.print(fax) }.to raise_error
        expect(fax.print_jobs).to be_empty
      end
    end
  end

  describe '#check' do
    let(:print_job) { create(:print_job) }

    before do
      allow(printer).to receive(:cups_job_statuses) { { } }
    end

    it 'updates cups_job_status of print jobs' do
      allow(printer).to receive(:cups_job_statuses).and_return(
        { print_job.cups_job_id => 'completed' }
      )
      printer.check [print_job]
      expect(print_job.cups_job_status).to eq 'completed'
    end
  end

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

    it 'caches result' do
      2.times { printer.send(:cups_job_statuses) }
      expect(Cups).to have_received(:all_jobs).once
    end
  end
end
