require 'spec_helper'

feature 'Fax Delivery' do
  let(:fax) { create(:fax) }
  let(:deliverer) { Fax::Deliverer.new(fax) }

  before do
    allow(deliverer).to receive(:deliver!)
    allow(Fax::Deliverer).to receive(:new).and_return(deliverer)
  end

  scenario 'delivers aborted fax' do
    fax.update(state: 'aborted')
    Fax.deliver
    expect(deliverer).to have_received(:deliver!)
  end

  scenario 'delivers undelivered fax' do
    fax.update(state: nil, print_job_id: nil)
    Fax.deliver
    expect(deliverer).to have_received(:deliver!)
  end

  scenario 'does not deliver completed fax' do
    fax.update(state: 'completed')
    Fax.deliver
    expect(deliverer).to_not have_received(:deliver!)
  end

  scenario 'does not deliver processing fax' do
    fax.update(state: nil)
    Fax.deliver
    expect(deliverer).to_not have_received(:deliver!)
  end
end
