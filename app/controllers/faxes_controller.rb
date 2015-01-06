class FaxesController < ApplicationController
  protect_from_forgery except: [:create, :create2]

  def index
    @faxes = faxes.updated_today
  end

  def show
    fax = Fax.find(params[:id]) # TODO: only render faxes for current user/recipient!
    send_file fax.document.path,
      type: fax.document.content_type,
      disposition: 'inline'
  end

  def create
    # See http://stackoverflow.com/questions/9758879/sending-files-to-a-rails-json-api !!!
    if params[:fax][:document]
      tempfile = Tempfile.new('fileupload')
      tempfile.binmode
      tempfile.write(Base64.decode64(params[:fax][:document][:data]))

      params[:fax][:document] = ActionDispatch::Http::UploadedFile.new(
        tempfile: tempfile,
        filename: params[:fax][:document][:filename],
        type:     params[:fax][:document][:type])
    end

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

  def create2
    fax = Fax.new(fax_params)
    if fax.save
      render json: 'OK', status: :created #TODO: Return more infos about the new fax!
    else
      render json: fax.errors, status: :unprocessable_entity
    end
  end

  def undeliverable
    @faxes = faxes.undeliverable
    render :index
  end

  def search
    @faxes = faxes.search(params[:q])
  end

  private

  def fax_params
    params.require(:fax).permit(:title, :phone, :document)
  end

  def faxes
    if params[:recipient_id]
      Recipient.find(params[:recipient_id]).faxes
    else
      Fax
    end.order('updated_at DESC')
  end
end
