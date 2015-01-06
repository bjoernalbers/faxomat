require 'spec_helper'

describe Delivery do
  let(:delivery) { build(:delivery) }

  it 'belongs to a fax' do
    fax = create(:fax)
    delivery = build(:delivery, fax: fax)
    expect(delivery.fax).to eq fax
  end

  context 'without a fax' do
    let(:delivery) { build(:delivery, fax: nil) }

    it 'is invalid' do
      expect(delivery).to be_invalid
      expect(delivery.errors[:fax]).to_not be_empty
    end

    it 'can not be saved in the database' do
      expect { delivery.save(validate: false) }.to raise_error
    end
  end

  context 'without a print_job_id' do
    let(:delivery) { build(:delivery, print_job_id: nil) }

    it 'is valid because we set it after validations' do
      expect(delivery).to be_valid
    end

    it 'can not be saved in the database' do
      # NOTE: Delivery#run! would set the print_job_id in the `before_create`
      # callback so we better disable it.
      allow(delivery).to receive(:run!)
      expect { delivery.save(validate: false) }.to raise_error
    end
  end

  it 'validates the uniqueness of the print_job_id' do
    delivery = create(:delivery)
    expect {
      create(:delivery, print_job_id: delivery.print_job_id)
    }.to raise_error
  end

  it 'has a factory that builds objects with unique print_job_id' do
    2.times {
      expect { create(:delivery) }.to_not raise_error
    }
  end
end
