require 'rails_helper'

RSpec.describe DeliveryJob, type: :job do
  it 'delivers the document' do
    document = create(:document)
    allow(Document).to receive(:deliver)
    DeliveryJob.perform_now(document.id)
    expect(Document).to have_received(:deliver).with(document.id)
  end
end
