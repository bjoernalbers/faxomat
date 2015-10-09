module API
  class ReportsController < ApplicationController
    before_action :set_default_format

    def self.report_attributes
      [
        :subject,
        :examination,
        :anamnesis,
        :diagnosis,
        :findings,
        :evaluation,
        :procedure,
        :clinic,
        :username,
        :patient_number,
        :patient_first_name,
        :patient_last_name,
        :patient_date_of_birth,
        :recipient_last_name,
        :recipient_first_name,
        :recipient_title,
        :recipient_suffix,
        :recipient_sex,
        :recipient_address,
        :recipient_zip,
        :recipient_city,
        :recipient_fax_number
      ]
    end

    skip_before_action :verify_authenticity_token, only: [:create]
    wrap_parameters :report, include: self.report_attributes

    def create
      api_report = Report.new(report_params)
      if api_report.save
        @report = api_report.report
        render :show, status: :created,
          location: api_report_url(@report)
      else
        render json: { errors: api_report.errors.full_messages },
          status: :unprocessable_entity
      end
    end

    def show
      @report = ::Report.find(params[:id])
      respond_to do |format|
        format.json { render :show, location: api_report_url(@report) }
        format.pdf  do
          pdf = ReportPdf.new(ReportPresenter.new(@report, view_context))
          #TODO: Replace hard-coded filename!
          send_data pdf.render, filename: 'foo.pdf', type: 'application/pdf'
        end

      end
    end

    private

    def report_params
      params.require(:report).permit(self.class.report_attributes)
    end

    def set_default_format
      # Set default format to JSON unless someone requests aPDF.
      request.format = :json unless params[:action] == 'show' &&
        request.format.pdf?
    end
  end
end
