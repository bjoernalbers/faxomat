class FaxesController < ApplicationController
  def index
    @faxes = faxes.all
  end

  def show
    fax = Fax.find(params[:id]) # TODO: only render faxes for current user/recipient!
    send_file fax.path, type: 'application/pdf', disposition: 'inline'
  end

  private

  def faxes
    if params[:recipient_id]
      recipient = Recipient.find(params[:recipient_id])
      recipient.faxes
    else
      Fax
    end
  end
end
