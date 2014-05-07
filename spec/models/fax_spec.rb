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

  describe '#verified?' do
    it 'returns nil by default (not implemented yet)' do
      expect(fax.verified?).to be_nil
    end
  end

  describe '#deliver' do
    before do
      fax.stub(:command).and_return('chunky bacon')
      fax.stub(:system)
    end

    it 'runs the system command' do
      fax.should_receive(:system).with('chunky bacon')
      fax.deliver
    end

    context 'with successfully finished command' do
      before do
        fax.stub(:system).and_return(true)
      end

      it 'saved the deliver time in the database' do
        now = Time.now
        Time.stub(:now).and_return(now)
        fax.deliver
        expect(fax.delivered_at).to eq now
      end
    end

    context 'without successfully finished command' do
      before do
        fax.stub(:system).and_return(false)
      end

      it 'does not save the deliver time in the database' do
        fax.deliver
        expect(fax.delivered_at).to be_nil
      end
    end
  end

  describe '#command' do
    it 'returns the command line for sending the fax' do
      fax.stub(:phone).and_return('042')
      fax.stub(:path).and_return('/tmp/foo.pdf')
      expect(fax.send(:command)).to eq("lp -d Fax -o phone=042 '/tmp/foo.pdf'")
    end
  end

  describe '#phone' do
    it 'returns the recipients phone number with prefixed zero' do
      recipient = create(:recipient, phone: '0123456789')
      fax = create(:fax, recipient: recipient)
      expect(fax.send(:phone)).to eq('00123456789')
    end
  end
end
