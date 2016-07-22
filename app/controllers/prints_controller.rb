class PrintsController < ApplicationController
  protect_from_forgery except: [:create]

  def index
    @prints = prints.active
  end

  def show
    print = Print.find(params[:id])
    send_file print.path, type: print.content_type
  end

  def create
    @print = Print.new(print_params)
    respond_to do |format|
      if @print.save
        flash[:notice] = 'Druckauftrag wird gesendet.'
        format.html { redirect_to(@print.document) }
        format.json { render json: 'OK', status: :created } #TODO: Return more infos about the new print!
      else
        format.html { render action: 'new' }
        format.json { render json: @print.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    print = Print.find(params[:id])
    print.destroy if print
    redirect_to aborted_prints_path
  end

  def new
    @print = Print.new
  end

  def aborted
    @prints = prints.aborted
    render :index
  end

  def search
    @prints = prints.search(params)
  end

  def filter
    @prints = prints.none # Return by default no prints

    # by fax_number
    if params[:fax_number]
      @prints = prints.where(fax_number: params[:fax_number])
    end

    # by creation time
    if params[:created]
      if params[:created].to_sym == :last_week
        @prints = @prints.created_last_week
      else
        @prints = prints.none
      end
    end
  end

  private

  def print_params
    params.require(:print).permit(:printer_id, :document_id)
  end

  def prints
    Print.all.order('updated_at DESC')
  end
end
