describe Printer do
  let(:printer) { Printer.new(printer_name: 'Fax') }

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
    context 'when initialized with defaults' do
      let(:printer) { Printer.new }

      it 'returns default driver' do
        expect(printer.driver_class).to eq Printer.default_driver_class
      end
    end

    context 'when initialized with :driver' do
      let(:custom_driver) { double('custom driver') }
      let(:printer) { Printer.new(driver_class: custom_driver) }

      it 'returns different driver' do
        expect(printer.driver_class).to eq custom_driver
      end
    end
  end

  describe '#print' do
    let(:fax) { build(:fax) }
    let(:driver) { double('driver') }

    before do
      allow(printer).to receive(:driver).and_return(driver)
    end

    it 'calls print on the default driver' do
      allow(driver).to receive(:print).and_return 78933
      expect(printer.print(fax)).to eq 78933
      expect(driver).to have_received(:print).with(fax)
    end
  end

  describe '#check' do
    let(:faxes) { [ build(:fax) ] }
    let(:driver) { double('driver') }

    before do
      allow(printer).to receive(:driver).and_return(driver)
    end

    it 'calls check on the default driver' do
      allow(driver).to receive(:check)
      printer.check(faxes)
      expect(driver).to have_received(:check).with(faxes)
    end
  end
end
