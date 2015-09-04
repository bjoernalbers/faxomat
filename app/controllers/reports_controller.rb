class ReportsController < ApplicationController
  def show
    @report = Report.find(params[:id])
  end

  def approve
    @report = Report.find(params[:id])
    @report.approved!
    redirect_to @report
  end
end
