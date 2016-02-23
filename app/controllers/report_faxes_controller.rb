class ReportFaxesController < ApplicationController
  # TODO: Test this!
  before_action :authenticate_user!

  def create
    load_report
    @report.deliver_as_fax
    redirect_to @report, notice: 'Druckauftrag wird gesendet.'
  end

  private

  def load_report
    @report = Report.find(params[:report_id])
  end
end
