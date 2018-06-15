class DeliveryJob < ActiveJob::Base
  queue_as :default

  def perform(document_id)
    Document.deliver(document_id)
  end
end
