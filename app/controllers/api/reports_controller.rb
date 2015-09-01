module API
  class ReportsController < ApplicationController
    def self.report_attributes
      [:subject, :content, :username]
    end

    skip_before_action :verify_authenticity_token, only: [:create]
    wrap_parameters :report, include: self.report_attributes

    def create
      @report = Report.new(report_params)
      if @report.save
        render :show, status: :created,
          location: api_report_url(@report.report)
      else
        render json: { errors: @report.errors.full_messages },
          status: :unprocessable_entity
      end
    end

    private

    def report_params
      params.require(:report).permit(self.class.report_attributes)
    end
  end
end
