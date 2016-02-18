describe Printer::TestDriver do
  let(:printer) { Printer::TestDriver.new(foo: :bar) }
  let(:fax) { double('fax') }

  describe '#print' do
    it 'returns integer' do
      expect(printer.print(fax)).to be_a Integer
    end

    it 'returns 6 digits' do
      expect(printer.print(fax).to_s.length).to eq 6
    end

    it 'returns random number' do
      expect(printer.print(fax)).not_to eq printer.print(fax)
    end
  end

  describe '#check' do
    it 'does nothing' do
      printer.check( [fax] )
    end
  end
end
