module DocumentsHelper
  def deliver_documents_count
    count = Document.to_deliver.count
    count.zero? ? nil : count
  end
end
