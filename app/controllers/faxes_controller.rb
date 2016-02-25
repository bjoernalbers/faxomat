class FaxesController < ApplicationController
  protect_from_forgery except: [:create]

  def create
    p = fax_params
    p[:fax_number] = p.delete(:phone)
    @fax = faxes.new(p)
    respond_to do |format|
      if @fax.save
        flash[:notice] = 'Fax wird gesendet.'
        format.html { redirect_to(@fax) }
        format.json { render json: 'OK', status: :created } #TODO: Return more infos about the new print_job!
      else
        format.html { render action: 'new' }
        format.json { render json: @fax.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def fax_params
    params.require(:fax).permit(:title, :phone, :document)
  end

  def faxes
    Printer.fax_printer.print_jobs
  end
end
