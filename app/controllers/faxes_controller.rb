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
    @fax = Fax.new(fax_params)
    respond_to do |format|
      if @fax.save
        flash[:notice] = 'Fax wird versendet...'
        format.html { redirect_to(@fax) }
        format.json { render json: 'OK', status: :created } #TODO: Return more infos about the new fax!
      else
        format.html { render action: "new" }
        format.json { render json: @fax.errors, status: :unprocessable_entity }
      end
    end
  end

  def new
    @fax = Fax.new
  end

  def undeliverable
    @faxes = faxes.undeliverable
    render :index
  end

  def search
    @faxes = faxes.search(params[:q])
  end

  def filter
    @faxes = faxes.none # Return by default no faxes

    # by phone
    if params[:phone]
      if recipient = Recipient.find_by(phone: params[:phone])
        @faxes = recipient.faxes
      else
        @faxes = faxes.none
      end
    end

    # by creation time
    if params[:created]
      if params[:created].to_sym == :last_week
        @faxes = @faxes.created_last_week
      else
        @faxes = faxes.none
      end
    end
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
