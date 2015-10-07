class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    # TODO: Test that only pending reports get displayed!
    @reports = current_user.reports.pending
  end

  def show
    @report = Report.find(params[:id])
    respond_to do |format|
      format.html
      # TODO: Test this stuff!
      format.pdf do
        pdf = ReportPdf.new(ReportPresenter.new(@report, view_context))
        #TODO: Replace hard-coded filename!
        send_data pdf.render, filename: 'foo.pdf', type: 'application/pdf', disposition: :inline
      end
    end
  end

  def approve
    @report = Report.find(params[:id])
    @report.approved!
    @report.deliver_as_fax unless @report.recipient.fax_number.nil? # TODO: Test this!
    # TODO: Test redirection!
    redirect_to reports_path, notice: "Arztbrief erfolgreich vidiert: #{@report.title}"
  end
end
