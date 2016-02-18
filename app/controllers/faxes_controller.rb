class FaxesController < ApplicationController
  protect_from_forgery except: [:create]

  def index
    @faxes = faxes.active
  end

  def show
    fax = Fax.find(params[:id])
    send_file fax.document.path, type: fax.document.content_type
  end

  def create
    @fax = Fax.new(fax_params)
    respond_to do |format|
      if @fax.save
        flash[:notice] = 'Fax wird versendet...'
        format.html { redirect_to(@fax) }
        format.json { render json: 'OK', status: :created } #TODO: Return more infos about the new fax!
      else
        format.html { render action: 'new' }
        format.json { render json: @fax.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    fax = Fax.find(params[:id])
    fax.destroy if fax
    redirect_to aborted_faxes_path
  end

  def new
    @fax = Fax.new
  end

  def aborted
    @faxes = faxes.aborted
    render :index
  end

  def search
    @faxes = faxes.search(params)
  end

  def filter
    @faxes = faxes.none # Return by default no faxes

    # by phone
    if params[:phone]
      if fax_number = FaxNumber.find_by(phone: params[:phone])
        @faxes = fax_number.faxes
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
    if params[:fax_number_id]
      FaxNumber.find(params[:fax_number_id]).faxes
    else
      Fax
    end.order('updated_at DESC')
  end
end
