class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    # TODO: Test that only pending reports get displayed!
    @reports = reports
  end

  def show
    load_report
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

  # TODO: Replace by "update" action!
  def verify
    load_report
    @report.update!(status: :verified)
    #@report.deliver_as_fax unless @report.recipient.fax_number.nil? # TODO: Find a better way to fax!
    # TODO: Test redirection!
    redirect_to reports_path, notice: "Arztbrief erfolgreich vidiert: #{@report.title}"
  end

  def destroy
    load_report
    if @report.destroy
      redirect_to reports_url, notice: 'Der Arztbrief wurde gelöscht.'
    else
      redirect_to @report, alert: @report.errors.full_messages
    end
  end

  private

  def load_report
    @report = Report.find(params[:id])
  end

  def reports
    if params[:pending] == 'false'
      current_user.reports.verified
    else
      current_user.reports.pending
    end
  end
end
