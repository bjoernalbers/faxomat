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

  def update
    load_report
    if @report.update(report_params)
      #@report.deliver_as_fax unless @report.recipient.fax_number.nil? # TODO: Find a better way to fax!
      redirect_to @report, notice: "Arztbrief erfolgreich aktualisiert."
    else
      render :show
    end
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

  def report_params
    params.permit(:status)
  end
end
