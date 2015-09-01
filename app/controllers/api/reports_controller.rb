module API
  class ReportsController < ApplicationController
    skip_before_action :verify_authenticity_token, only: [:create]

    def create
      #@report = Report.new(report_params)
      @report = ReportApi.new(report_params)
      if @report.save
        #render :show, status: :created, location: api_report_url(@report)
        render :show, status: :created, location: api_report_url(@report.report)
      else
        render json: { errors: @report.errors.full_messages },
          status: :unprocessable_entity
      end
    end

    private

    def report_params
      params.require(:report).permit(:subject, :content, :username)
    end
  end
end
