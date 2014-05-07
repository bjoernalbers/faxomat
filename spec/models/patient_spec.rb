require 'spec_helper'

describe Patient do
  let(:patient) { build(:patient) }

  context 'without first_name' do
    let(:patient) { build(:patient, first_name: nil) }

    it 'is invalid' do
      expect(patient).to be_invalid
      expect(patient.errors_on(:first_name)).to_not be_empty
    end

    it 'can not be saved in the database' do
      expect { patient.save!(validate: false) }.to raise_error
    end
  end

  context 'without last_name' do
    let(:patient) { build(:patient, last_name: nil) }

    it 'is invalid' do
      expect(patient).to be_invalid
      expect(patient.errors_on(:last_name)).to_not be_empty
    end

    it 'can not be saved in the database' do
      expect { patient.save!(validate: false) }.to raise_error
    end
  end

  context 'without date_of_birth' do
    let(:patient) { build(:patient, date_of_birth: nil) }

    it 'is invalid' do
      expect(patient).to be_invalid
      expect(patient.errors_on(:date_of_birth)).to_not be_empty
    end

    it 'can not be saved in the database' do
      expect { patient.save!(validate: false) }.to raise_error
    end
  end

  it 'cleans first_name before save' do
    patient.update first_name: ' Chuck '
    expect(patient.first_name).to eq 'Chuck'
  end

  it 'cleans last_name before save' do
    patient.update last_name: ' Norris '
    expect(patient.last_name).to eq 'Norris'
  end

  it 'strips whitespaces from the name'

  it 'capitalizes the name' do
    patient.update first_name: 'chuck'
    expect(patient.first_name).to eq 'Chuck'
  end

  it 'capitalizes last_name' do
    patient.update last_name: 'chuck'
    expect(patient.last_name).to eq 'Chuck'
  end

  it 'strips unallowed symbols from the name'

  it 'has many faxes' do
    expect(patient).to respond_to(:faxes)
  end

  it 'has many recipients through faxes'

  describe '#info' do
    it 'returns patient attributes as string' do
      patient = build(:patient,
                      first_name: 'Homer',
                      last_name: 'Simpson',
                      date_of_birth: '1970-01-01')
      expect(patient.info).to eq 'Simpson, Homer (*1970-01-01)'
    end
  end

end
