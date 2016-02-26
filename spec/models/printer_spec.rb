describe Printer do
  let(:printer) { build(:printer) }

  it 'has valid factory' do
    expect(printer).to be_valid
  end

  it 'has factory to build fax printer' do
    printer = build(:fax_printer)
    expect(printer.is_fax_printer).to be true
  end

  it { expect(printer).to have_many(:print_jobs) }

  describe '.fax_printer' do
    let(:printer) { Printer.fax_printer }

    context 'with seeded database' do
      before do
        Rails.application.load_seed
      end

      it 'returns fax printer' do
        expect(printer).to be_present
        expect(printer.name).to eq 'Fax'
        expect(printer.label).to eq 'Faxgerät'
        expect(printer.is_fax_printer).to be true
      end
    end
  end

  describe '#name' do
    it { expect(printer).to validate_presence_of(:name) }

    it { expect(printer).to validate_uniqueness_of(:name) }

    it 'can not be stored when not unique' do
      printer.name = create(:printer).name
      expect{ printer.save!(validate: false) }.to raise_error
    end
  end

  describe '#label' do
    it { expect(printer).to validate_presence_of(:label) }
  end

  describe '#dialout_prefix' do
    it { expect(printer).not_to validate_presence_of(:dialout_prefix) }
  end

  describe '#is_fax_printer' do
    it { expect(printer).not_to validate_presence_of(:is_fax_printer) }
  end

  describe '#update_active_print_jobs' do
    let(:driver) { double('driver') }

    before do
      allow(printer).to receive(:driver).and_return(driver)
      allow(printer).to receive(:active_print_jobs).and_return(:active_print_jobs)
      allow(driver).to receive(:check)
    end

    it 'updates all active print jobs via driver' do
      printer.update_active_print_jobs
      expect(driver).to have_received(:check).with(:active_print_jobs)
    end
  end

  describe '.default_driver_class' do
    before do
      @default_driver_class = Printer.default_driver_class
    end

    after do
      Printer.default_driver_class = @default_driver_class
    end

    it 'returns cups driver when not set' do
      Printer.default_driver_class = nil
      expect(Printer.default_driver_class).to eq Printer::CupsDriver
    end

    it 'returns fake driver in test environment' do
      expect(Printer.default_driver_class).to eq Printer::TestDriver
    end
  end

  describe '#driver_class' do
    let(:printer) { Printer.new }

    it 'returns default driver' do
      expect(printer.driver_class).to eq Printer.default_driver_class
    end
  end

  describe '#print' do
    let(:print_job) { create(:print_job, cups_job_id: nil, status: nil) }

    it 'updates the print_job' do
      printer.print(print_job)
      print_job.reload
      expect(print_job.cups_job_id).to be_present
      expect(print_job).to be_active
    end
  end

  describe '#driver' do
    let(:printer) { build(:printer, name: 'R2D2', dialout_prefix: 2) }
    let(:driver_class) { double('driver_class') }

    before do
      allow(printer).to receive(:driver_class).and_return(driver_class)
      allow(driver_class).to receive(:new).and_return(:a_driver_instance)
    end

    it 'initializes and returns new driver' do
      expect(printer.driver).to eq :a_driver_instance
      expect(driver_class).to have_received(:new).with(printer)
    end
  end
end
