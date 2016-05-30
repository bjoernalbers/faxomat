class DocumentsController < ApplicationController
  before_action :load_document, only: [ :show, :download ]
  before_action :load_documents, only: :index

  def index
  end

  def show
  end

  def download
    send_file @document.path, type: @document.content_type
  end

  private

  def load_document
    @document = Document.find(params[:id])
  end

  def load_documents
    @documents = Document.delivered_today
  end
end
