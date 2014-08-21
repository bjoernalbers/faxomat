class FaxesController < ApplicationController
  protect_from_forgery except: :create

  def index
    @faxes = faxes.created_today
  end

  def show
    fax = Fax.find(params[:id]) # TODO: only render faxes for current user/recipient!
    send_file fax.document.path,
      type: fax.document.content_type,
      disposition: 'inline'
  end

  def create
    # See http://stackoverflow.com/questions/9758879/sending-files-to-a-rails-json-api !!!

    # Check if the file was uploaded via JSON (otherwise we'd get some multipart form).
    # NOTE: Inside this block we can't use `fax_params` since the attributes
    # from a multipart form are a bit different than our little JSON request.
    #if params[:fax][:document][:data]
    if params[:fax][:document]
      tempfile = Tempfile.new('fileupload')
      tempfile.binmode
      tempfile.write(Base64.decode64(params[:fax][:document][:data]))

      params[:fax][:document] = ActionDispatch::Http::UploadedFile.new(
        tempfile: tempfile,
        filename: params[:fax][:document][:filename],
        type:     params[:fax][:document][:type])
    end

    #if fax_params[:document]
      #tempfile = Tempfile.new('fileupload')
      #tempfile.binmode
      #tempfile.write(Base64.decode64(fax_params[:document][:data]))
#
      #fax_params[:document] = ActionDispatch::Http::UploadedFile.new(
        #tempfile: tempfile,
        #filename: fax_params[:document][:filename],
        #type:     fax_params[:document][:type])
    #end
    # start hacking
    
    # stop hacking
    #fax = Fax.new(params[:fax])
    fax = Fax.new(fax_params)

    if fax.save
      render json: 'OK', status: :created #TODO: Return more infos about the new fax!
    else
      render json: fax.errors, status: :unprocessable_entity
    end
  ensure
    if tempfile
      tempfile.close
      tempfile.unlink
    end
  end

  def aborted
    @faxes = faxes.aborted
    render :index
  end

  def search
    @faxes = faxes.search(params[:q])
  end

  private

  def fax_params
    #params.require(:fax).permit(:path, :phone)
    params.require(:fax).permit(:title, :phone, :document)
    #params.require(:fax).permit(:title, :phone, document: [:filename, :type, :data])
  end

  def faxes
    if params[:recipient_id]
      recipient = Recipient.find(params[:recipient_id])
      recipient.faxes
    else
      Fax
    end
  end
end
