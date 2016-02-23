class PrintJobsController < ApplicationController
  protect_from_forgery except: [:create]

  def index
    @print_jobs = print_jobs.active
  end

  def show
    print_job = PrintJob.find(params[:id])
    send_file print_job.document.path, type: print_job.document.content_type
  end

  def create
    @print_job = PrintJob.new(print_job_params)
    respond_to do |format|
      if @print_job.save
        flash[:notice] = 'Druckauftrag wird gesendet.'
        format.html { redirect_to(@print_job) }
        format.json { render json: 'OK', status: :created } #TODO: Return more infos about the new print_job!
      else
        format.html { render action: 'new' }
        format.json { render json: @print_job.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    print_job = PrintJob.find(params[:id])
    print_job.destroy if print_job
    redirect_to aborted_print_jobs_path
  end

  def new
    @print_job = PrintJob.new
  end

  def aborted
    @print_jobs = print_jobs.aborted
    render :index
  end

  def search
    @print_jobs = print_jobs.search(params)
  end

  def filter
    @print_jobs = print_jobs.none # Return by default no print_jobs

    # by phone
    if params[:phone]
      if fax_number = FaxNumber.find_by(phone: params[:phone])
        @print_jobs = fax_number.print_jobs
      else
        @print_jobs = print_jobs.none
      end
    end

    # by creation time
    if params[:created]
      if params[:created].to_sym == :last_week
        @print_jobs = @print_jobs.created_last_week
      else
        @print_jobs = print_jobs.none
      end
    end
  end

  private

  def print_job_params
    params.require(:print_job).permit(:title, :phone, :document)
  end

  def print_jobs
    if params[:fax_number_id]
      FaxNumber.find(params[:fax_number_id]).print_jobs
    else
      PrintJob
    end.order('updated_at DESC')
  end
end
