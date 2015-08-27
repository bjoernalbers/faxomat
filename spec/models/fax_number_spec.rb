describe FaxNumber do
  it 'has a factory that builds valid models' do
    2.times { expect(create(:fax_number)).to be_valid }
  end

  describe '#to_s' do
    it 'returns number as string' do
      fax_number = build(:fax_number)
      expect(fax_number.to_s).to eq fax_number.phone
    end
  end

  context 'without phone' do
    let(:fax_number) { build(:fax_number, phone: nil) }

    it 'is invalid' do
      expect(fax_number).to be_invalid
      expect(fax_number.errors[:phone]).to_not be_empty
    end

    it 'can not be saved in the database' do
      expect { fax_number.save!(validate: false) }.to raise_error
    end
  end

  context 'with a non-unique phone' do
    let(:phone) { '0123456789' }
    let(:fax_number) { build(:fax_number, phone: phone) }
    
    before do
      create(:fax_number, phone: phone)
    end

    it 'is invalid' do
      expect(fax_number).to be_invalid
      expect(fax_number.errors[:phone].count).to eq 1
    end

    it 'can not be saved in the database' do
      expect { fax_number.save!(validate: false) }.to raise_error
    end
  end

  it 'cleans the phone number from non-digits before save' do
    phone = ' 0123-456 789 '
    fax_number = create(:fax_number, phone: phone)
    expect(fax_number.phone).to eq '0123456789'
  end

  it 'is invalid with too short phone' do
    fax_number = build(:fax_number, phone: '0123456')
    fax_number.valid?
    expect(fax_number.errors[:phone].count).to eq 1
  end

  it 'is invalid when phone has no leading zero' do
    fax_number = build(:fax_number, phone: '123456789')
    expect(fax_number).to be_invalid
    expect(fax_number.errors[:phone].count).to eq 1
    expect(fax_number.errors[:phone]).to include('has no area code')
  end

  it 'is invalid when phone has more then one leading zero' do
    fax_number = build(:fax_number, phone: '00123456789')
    expect(fax_number).to be_invalid
    expect(fax_number.errors[:phone].count).to eq 1
    expect(fax_number.errors[:phone]).to include('has no area code')
  end
end
