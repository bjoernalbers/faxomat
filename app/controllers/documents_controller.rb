class DocumentsController < ApplicationController
  before_action :load_document, only: [ :show, :download ]

  def index
    @documents = Document.created_today
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
end
