class DocumentsController < ApplicationController
  def show
    load_document
    send_file @document.path, type: @document.content_type
  end

  private

  def load_document
    @document = Document.find(params[:id])
  end
end
