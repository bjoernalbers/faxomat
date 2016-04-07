module API
  class ReportsController < ApplicationController
    before_action :set_default_format

    def self.report_attributes
      [
        :study,
        :study_date,
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
        :recipient_salutation,
        :recipient_address,
        :recipient_zip,
        :recipient_city,
        :recipient_fax_number
      ]
    end

    skip_before_action :verify_authenticity_token, only: [:create, :update]
    wrap_parameters :report, include: self.report_attributes

    def create
      @report = Report.new(report_params)
      if @report.save
        @message = 'Bericht erfolgreich angelegt'
        render :show, status: :created, location: api_report_url(@report)
      else
        @message = 'Bericht ist fehlerhaft'
        render :show, status: :unprocessable_entity
      end
    end

    def update
      load_report
      @report.attributes = report_params
      if @report.save
        @message = 'Bericht erfolgreich aktualisiert'
        render :show, status: :ok, location: api_report_url(@report)
      else
        @message = 'Bericht ist fehlerhaft'
        render :show, status: :unprocessable_entity
      end
    end

    def show
      @report = ::Report.find(params[:id])
      respond_to do |format|
        format.json { render :show, location: api_report_url(@report) }
        format.pdf  do
          pdf = ReportPdf.new(@report)
          send_data pdf.render, filename: pdf.filename, type: 'application/pdf'
        end
      end
    end

    private

    def load_report
      @report = Report.find(params[:id])
    end

    def report_params
      params.require(:report).permit(self.class.report_attributes)
    end

    def set_default_format
      # Set default format to JSON unless someone requests a PDF.
      request.format = :json unless params[:action] == 'show' &&
        request.format.pdf?
    end
  end
end
