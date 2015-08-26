describe Recipient do
  it 'has a factory that builds valid models' do
    2.times { expect(create(:recipient)).to be_valid }
  end

  context 'without phone' do
    let(:recipient) { build(:recipient, phone: nil) }

    it 'is invalid' do
      expect(recipient).to be_invalid
      expect(recipient.errors[:phone]).to_not be_empty
    end

    it 'can not be saved in the database' do
      expect { recipient.save!(validate: false) }.to raise_error
    end
  end

  context 'with a non-unique phone' do
    let(:phone) { '0123456789' }
    let(:recipient) { build(:recipient, phone: phone) }
    
    before do
      create(:recipient, phone: phone)
    end

    it 'is invalid' do
      expect(recipient).to be_invalid
      expect(recipient.errors[:phone].count).to eq 1
    end

    it 'can not be saved in the database' do
      expect { recipient.save!(validate: false) }.to raise_error
    end
  end

  it 'cleans the phone number from non-digits before save' do
    phone = ' 0123-456 789 '
    recipient = create(:recipient, phone: phone)
    expect(recipient.phone).to eq '0123456789'
  end

  it 'is invalid with too short phone' do
    recipient = build(:recipient, phone: '0123456')
    recipient.valid?
    expect(recipient.errors[:phone].count).to eq 1
  end

  it 'is invalid when phone has no leading zero' do
    recipient = build(:recipient, phone: '123456789')
    expect(recipient).to be_invalid
    expect(recipient.errors[:phone].count).to eq 1
    expect(recipient.errors[:phone]).to include('has no area code')
  end

  it 'is invalid when phone has more then one leading zero' do
    recipient = build(:recipient, phone: '00123456789')
    expect(recipient).to be_invalid
    expect(recipient.errors[:phone].count).to eq 1
    expect(recipient.errors[:phone]).to include('has no area code')
  end
end
