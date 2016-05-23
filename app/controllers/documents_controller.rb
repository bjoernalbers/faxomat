class DocumentsController < ApplicationController
  def download
    load_document
    send_file @document.path, type: @document.content_type
  end

  private

  def load_document
    @document = Document.find(params[:id])
  end
end
