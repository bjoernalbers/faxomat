module API
  class PrintJobsController < ApplicationController
    def index
      @print_jobs = print_jobs
    end

    private

    def print_jobs
      PrintJob.all
    end
  end
end
