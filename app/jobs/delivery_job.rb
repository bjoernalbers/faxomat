class DeliveryJob < ActiveJob::Base
  queue_as :default

  def perform(document_id)
    document = Document.find(document_id)
    #Document::Deliverer.new(document).deliver
    Document.deliver(document_id)
  end
end
