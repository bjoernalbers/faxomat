require 'spec_helper'

describe Fax do
  let(:fax) { build(:fax) }

  it 'validates that path points to an existing file' do
    pending
  end

  context 'without a path' do
    let(:fax) { build(:fax, path: nil) }

    it 'is invalid' do
      expect(fax).to be_invalid
      expect(fax).to have(1).errors_on(:path)
    end

    it 'can not be saved in the database' do
      expect { fax.save!(validate: false) }.to raise_error
    end
  end

  context 'without a recipient' do
    let(:fax) { build(:fax, recipient: nil) }

    it 'is invalid' do
      expect(fax).to be_invalid
      expect(fax).to have(1).errors_on(:recipient)
    end

    it 'can not be saved in the database' do
      expect { fax.save!(validate: false) }.to raise_error
    end
  end

  context 'without a patient' do
    let(:fax) { build(:fax, patient: nil) }

    it 'is invalid' do
      expect(fax).to be_invalid
      expect(fax).to have(1).errors_on(:patient)
    end

    it 'can not be saved in the database' do
      expect { fax.save!(validate: false) }.to raise_error
    end
  end

  describe '#status' do
    context 'when not verified' do
      before do
        fax.stub(:verified?).and_return(false)
      end

      it 'returns nil' do
        expect(fax.status).to be_nil
      end
    end

    context 'when verified' do
      before do
        fax.stub(:verified?).and_return(true)
      end

      it 'returns :completed on success' do
        fax.stub(:success?).and_return(true)
        expect(fax.status).to eq :completed
      end

      it 'returns :aborted on failure' do
        fax.stub(:success?).and_return(false)
        expect(fax.status).to eq :aborted
      end
    end
  end

  describe '.ordered_by_last_delivery' do
    let(:fax) { create(:fax) }

    before do
      create(:delivery, fax: fax)
    end

    it 'returns last delivered faxes first' do
      last_delivered_fax = create(:fax)
      create(:delivery, fax: last_delivered_fax,
             created_at: DateTime.now + 1.hour)

      faxes = Fax.ordered_by_last_delivery

      # Broken with --seed 54172
      expect(faxes.count).to eq 2 #debug
      expect(faxes.first).to eq last_delivered_fax
      expect(faxes.last).to eq fax
    end

    it 'returns undelivered faxes on top' do
      undelivered_fax = create(:fax)

      faxes = Fax.ordered_by_last_delivery

      # Broken with --seed 54172
      expect(faxes.count).to eq 2 #debug
      expect(faxes.first).to eq undelivered_fax
      expect(faxes.last).to eq fax
    end
  end

  describe '#verified?' do
    it 'returns nil by default (not implemented yet)' do
      expect(fax.verified?).to be_nil
    end
  end

  describe '#delivered?' do
  end

  describe '#verify' do
    context 'when delivered' do
      it 'updates the print job status'
      it 'returns true'
    end

    context 'when not delivered' do
      it 'does not update the status'
      it 'returns false'
    end
  end

  describe '#phone' do
    it 'returns the recipients phone number' do
      recipient = create(:recipient, phone: '0123456789')
      fax = create(:fax, recipient: recipient)
      expect(fax.phone).to eq recipient.phone
    end
  end

  it 'has many deliveries' do
    expect(fax).to respond_to(:deliveries)
  end

  it 'destroys dependend deliveries' do
    fax = create(:fax)
    2.times { create(:delivery, fax: fax) }
    expect(fax.deliveries).to_not be_empty
    fax.destroy
    expect(fax.deliveries).to be_empty
  end

  describe '#title' do
    it 'returns the patient infos' do
      patient = double('patient', info: 'hey')
      fax.stub(:patient).and_return(patient)
      expect(fax.title).to eq 'hey'
    end
  end

  describe '#deliver!' do
    it 'creates a new delivery'
  end

  describe '#state' do
    let(:fax) { create(:fax) }

    context 'when delivered' do
      let!(:first_delivery) { create(:delivery, fax: fax, print_job_state: 'awesome') }
      let!(:last_delivery) { create(:delivery, fax: fax, print_job_state: 'awesome',
                                   created_at: first_delivery.created_at + 1.second) }

      it 'returns the last delivery state' do
        expect(fax.state).to eq(last_delivery.print_job_state)
      end
    end

    context 'when not delivered' do
      it 'returns nil' do
        expect(fax.state).to be_nil
      end
    end
  end

  describe '#last_delivery_at' do
    let(:fax) { create(:fax) }

    it 'returns the creation time for the last delivery' do
      first_delivery = create(:delivery, fax: fax)
      last_delivery = create(:delivery, fax: fax,
                             created_at: first_delivery.created_at + 1.second)
      expect(fax.last_delivery_at).to eq(last_delivery.created_at)
    end

    it 'does not raise without deliveries' do
      expect { fax.last_delivery_at }.to_not raise_error
    end
  end
end
