describe Printer::TestDriver do
  let(:driver) { Printer::TestDriver.new(build(:printer)) }
  let(:fax) { double('fax') }

  describe '#print' do
    it 'returns integer' do
      expect(driver.print(fax)).to be_a Integer
    end

    it 'returns 6 digits' do
      expect(driver.print(fax).to_s.length).to eq 6
    end

    it 'returns random number' do
      expect(driver.print(fax)).not_to eq driver.print(fax)
    end
  end

  describe '#check' do
    it 'does nothing' do
      driver.check( [fax] )
    end
  end
end
