class ExportsController < ApplicationController
  before_action :load_document

  def new
    build_document
  end

  def create
    build_document
    @export.attributes = export_params
    if @export.save
      flash[:notice] = "Dokument wurde als \"#{@export.filename}\" exportiert."
      redirect_to @document
    else
      render :new
    end
  end

  private

  def build_document
    @export = Export.new(document: @document)
  end

  def load_document
    @document = Document.find(params[:document_id])
  end

  def export_params
    params.require(:export).permit(:directory_id)
  end
end
