describe Print::HylafaxDriver do
  let(:subject) { described_class.new(build(:print)) }

  describe '.statuses' do
    let(:printer) { build(:hylafax_printer) }

    before do
      allow(HylaFAX).to receive(:faxstat) {
        { 1 => :done, 2 => :failed, 3 => :chunky } }
    end

    it 'queries hylafax for statuses' do
      described_class.statuses(printer)
      expect(HylaFAX).to have_received(:faxstat).
        with(host: printer.host,
             port: printer.port,
             user: printer.user,
             password: printer.password,
             passive: true)
    end

    it 'converts and returns hash of hylafax job statuses' do
      expect(described_class.statuses(printer)).
        to eq({ 1 => :completed, 2 => :aborted, 3 => :active })
    end
  end

  describe '#run' do
    let(:printer) { build(:hylafax_printer, dialout_prefix: 0) }
    let(:print) { build(:print, printer: printer) }
    subject { described_class.new(print) }

    before do
      allow(HylaFAX).to receive(:sendfax) { 42 }
    end

    it 'sends the fax' do
      subject.run
      expect(HylaFAX).to have_received(:sendfax).
        with(host: printer.host,
             port: printer.port,
             user: printer.user,
             password: printer.password,
             dialstring: printer.dialout_prefix.to_s + print.fax_number,
             document: print.path,
             passive: true)
    end

    it 'returns job_number' do
      expect(subject.run).to eq 42
    end

    it 'assigns job_number' do
      subject.run
      expect(subject.job_number).to eq 42
    end
  end
end
