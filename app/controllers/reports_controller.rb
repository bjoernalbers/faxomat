class ReportsController < ApplicationController
  before_action :authenticate_user!

  def index
    # TODO: Test that only pending reports get displayed!
    @reports = current_user.reports.pending
  end

  def show
    @report = Report.find(params[:id])
  end

  def approve
    @report = Report.find(params[:id])
    @report.approved!
    # TODO: Test redirection!
    redirect_to reports_path, notice: "Arztbrief erfolgreich vidiert: #{@report.title}"
  end
end
