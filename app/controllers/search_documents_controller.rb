class SearchDocumentsController < DocumentsController
  private

  def load_documents
    @documents = Document.search(params)
  end
end
