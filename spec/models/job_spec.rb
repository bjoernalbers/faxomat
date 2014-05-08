require 'spec_helper'

describe Job do
  let(:job) { build(:job) }

  describe '.from_json' do
    it 'returns a new job instance from JSON attributes' do
      json = '{"phone":"0123456789"}'
      expect(Job.from_json(json)).to be_a Job
    end

    it 'sets the phone number' do
      json = '{"phone":"0123456789"}'
      expect(Job.from_json(json).phone).to eq '0123456789'
    end

    it 'sets the path' do
      json = '{"path":"/tmp/letter.pdf"}'
      expect(Job.from_json(json).path).to eq '/tmp/letter.pdf'
    end

    it 'sets the patient_first_name' do
      json = '{"patient_first_name": "Chuck"}'
      expect(Job.from_json(json).patient_first_name).to eq 'Chuck'
    end

    it 'sets the patient_last_name' do
      json = '{"patient_last_name":"Norris"}'
      expect(Job.from_json(json).patient_last_name).to eq 'Norris'
    end

    it 'sets the patient_date_of_birth' do
      json = '{"patient_date_of_birth":"1940-03-10"}'
      expect(Job.from_json(json).patient_date_of_birth).to eq '1940-03-10'
    end
  end

  describe '#save' do
    let(:recipient) { double('recipient') }
    let(:patient) { double('patient') }
    let(:fax) { double('fax') }

    before do
      job.stub(:recipient).and_return(recipient)
      job.stub(:patient).and_return(patient)
      job.stub(:fax).and_return(fax)
    end

    it 'saves the models in the right order' do
      recipient.should_receive(:save).ordered.and_return(true)
      patient.should_receive(:save).ordered.and_return(true)
      fax.should_receive(:save).ordered.and_return(true)
      job.save
    end

    it 'returns true when all models are saved' do
      recipient.stub(:save).and_return(true)
      patient.stub(:save).and_return(true)
      fax.stub(:save).and_return(true)
      expect(job.save).to be_true
    end

    it 'returns false when one model could not be saved' do
      recipient.stub(:save).and_return(true)
      patient.stub(:save).and_return(true)
      fax.stub(:save).and_return(false)
      expect(job.save).to be_false
    end

    it 'does not save the fax when the recipient could not be saved' do
      recipient.stub(:save).and_return(false)
      patient.stub(:save).and_return(true)
      fax.should_not_receive(:save)
      expect(job.save).to be_false
    end
  end

  describe '#process' do
    context 'when successfully saved' do
      it 'delivers the fax'
      it 'returns true'
    end

    context 'when not successfully saved' do
      it 'does not deliver the fax'
      it 'returns false'
    end
  end

  describe '#recipient' do
    let(:recipient) { double('recipient') }

    it 'finds or initializes a recipient by phone' do
      job.stub(:phone).and_return('0123456789')
      Recipient.should_receive(:find_or_initialize_by).
        with(phone: '0123456789').and_return(recipient)
      job.send(:recipient)
    end

    it 'returns a cached object' do
      Recipient.should_receive(:find_or_initialize_by).once.
        and_return(recipient)
      2.times { expect(job.send(:recipient)).to eq recipient }
    end
  end

  describe '#patient' do
    let(:patient) { double('patient') }

    it 'finds or initializes a patient' do
      Patient.should_receive(:find_or_initialize_by).
        with(first_name: 'Chuck',
             last_name: 'Norris',
             date_of_birth: '1940-03-10').and_return(patient)
      job.send(:patient)
    end

    it 'returns a cached object' do
      Patient.should_receive(:find_or_initialize_by).once.
        and_return(patient)
      2.times { expect(job.send(:patient)).to eq patient }
    end
  end

  describe '#fax' do
    it 'initializes a new fax' do
      job = build(:job, path: '/tmp/letter.pdf')
      recipient = create(:recipient)
      patient = create(:patient)
      job.stub(:recipient).and_return(recipient)
      job.stub(:patient).and_return(patient)

      Fax.should_receive(:new).
        with(path: '/tmp/letter.pdf',
             recipient: recipient,
             patient: patient)

      job.send(:fax)
    end

    it 'returns a cached object' do
      fax = double('fax')
      Fax.should_receive(:new).once.and_return(fax)
      2.times { expect(job.send(:fax)).to eq fax }
    end
  end
end
