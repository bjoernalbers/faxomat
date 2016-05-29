class DeliverDocumentsController < DocumentsController
  private

  def load_documents
    @documents = Document.to_deliver
  end
end
