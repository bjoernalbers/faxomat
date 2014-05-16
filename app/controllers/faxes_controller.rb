class FaxesController < ApplicationController
  def index
    @faxes = faxes.ordered_by_last_delivery.limit(100) #TODO: Add test and refactor!
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
