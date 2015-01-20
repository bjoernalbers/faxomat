class FaxesController < ApplicationController
  protect_from_forgery except: [:create]

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

  def harmsen
    @faxes = Recipient.find_by(phone: '0294118673').faxes.created_last_week
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
