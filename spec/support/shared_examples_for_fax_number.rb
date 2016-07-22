shared_examples 'should validate fax_number' do
  it 'validates minimum length' do
    subject.fax_number = '0123456'
    expect(subject).to be_invalid
    expect(subject.errors[:fax_number]).to be_present
    subject.fax_number = '01234567'
    expect(subject).to be_valid
  end

  it 'validates excactly one leading zero' do
    %w(123456789  00123456789).each do |fax_number|
      subject.fax_number = fax_number
      expect(subject).to be_invalid
      expect(subject.errors[:fax_number]).to be_present
    end
  end

  it 'adds a nice error message' do
    subject.fax_number = '0123456'
    expect(subject).to be_invalid
    expect(subject.errors[:fax_number]).
      to include('ist keine gültige nationale Faxnummer mit Vorwahl')
  end
end

