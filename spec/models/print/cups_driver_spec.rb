describe Print::CupsDriver do
  let(:print) { build(:print) }
  let(:subject) { described_class.new(print) }

  describe '.statuses' do
    let(:subject) { described_class }

    before do
      allow(Cups).to receive(:all_jobs).and_return( {} )
    end

    it 'queries CUPS jobs by printer name' do
      subject.statuses('printer name')
      expect(Cups).to have_received(:all_jobs).with('printer name')
    end

    it 'converts and returns hash of print job statuses' do
      allow(Cups).to receive(:all_jobs).and_return({
        1 => { state: :completed },
        2 => { state: :aborted   },
        3 => { state: :cancelled },
        4 => { state: :active    },
        5 => { state: :chunky    }
      })
      expect(subject.statuses('printer name')).to eq({
        1 => :completed,
        2 => :aborted,
        3 => :aborted,
        4 => :active,
        5 => :active
      })
    end
  end

  describe '#run' do
    let(:cups_job) { double('cups_job') }

    before do
      allow(Cups::PrintJob).to receive(:new).and_return(cups_job)

      allow(cups_job).to receive(:title=)
      allow(cups_job).to receive(:print) { true }
      allow(cups_job).to receive(:job_id) { 42 }

      allow(print).to receive(:path).and_return('chunky_bacon.pdf')
      allow(print).to receive(:fax_number).and_return('012456789')
    end

    context 'with fax printer' do
      let(:printer) { build(:fax_printer) }

      before { print.printer = printer }

      it 'prints as CUPS fax print' do
        subject.run
        expect(Cups::PrintJob).to have_received(:new).
          with('chunky_bacon.pdf', printer.name, {'phone' =>
               "#{printer.dialout_prefix}#{print.fax_number}"})
        expect(cups_job).to have_received(:print)
      end
    end

    context 'with paper printer' do
      let(:printer) { build(:paper_printer) }

      before { print.printer = printer }

      it 'prints as CUPS print' do
        subject.run
        expect(Cups::PrintJob).to have_received(:new).
          with('chunky_bacon.pdf', printer.name)
        expect(cups_job).to have_received(:print)
      end
    end

    it 'sets print job title' do
      subject.run
      expect(cups_job).to have_received(:title=).with(print.title)
    end

    it 'returns CUPS job ID' do
      allow(cups_job).to receive(:print).and_return(:chunky_bacon)
      expect(subject.run).to eq :chunky_bacon
    end
  end

  describe '#job_id' do
    let(:cups_job) { double('cups_job') }

    before do
      allow(subject).to receive(:cups_job).and_return(cups_job)
    end

    it 'returns job_id when cups_job job_id is non-zero' do
      allow(cups_job).to receive(:job_id).and_return(42)
      expect(subject.job_id).to eq 42
    end

    it 'returns nil when cups_job job_id is zero' do
      allow(cups_job).to receive(:job_id).and_return(0)
      expect(subject.job_id).to eq nil
    end
  end

  describe '#cups_job' do
    let(:cups_job) { double('cups_job') }

    before do
      allow(subject).to receive(:build_cups_job).and_return(cups_job)
    end

    it 'returns cached cups_job' do
      2.times { expect(subject.send(:cups_job)).to eq cups_job }
      expect(subject).to have_received(:build_cups_job).once
    end
  end
end
