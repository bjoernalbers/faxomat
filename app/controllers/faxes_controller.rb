class FaxesController < ApplicationController
  protect_from_forgery except: :create

  def index
    @faxes = faxes.created_today
  end

  def show
    fax = Fax.find(params[:id]) # TODO: only render faxes for current user/recipient!
    send_file fax.path, type: 'application/pdf', disposition: 'inline'
  end

  def create
    fax = Fax.new(fax_params)
    if fax.save
      render json: 'OK', status: :created #TODO: Return more infos about the new fax!
    else
      render json: fax.errors, status: :unprocessable_entity
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
    params.require(:fax).permit(:path, :phone)
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
