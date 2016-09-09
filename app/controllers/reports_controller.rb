class ReportsController < ApplicationController
  before_action :authenticate_user!, except: [ :show ]

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
        pdf = ReportPdf.new(@report)
        send_data pdf.render, filename: pdf.filename, type: 'application/pdf'
      end
    end
  end

  def update
    load_user_report
    if @report.update(report_params)
      redirect_to @report, notice: "Arztbrief erfolgreich aktualisiert."
    else
      render :show
    end
  end

  def verify
    load_user_report
    if @report.pending?
      @report.verify!
      redirect_to reports_url, notice: "Arztbrief erfolgreich vidiert."
    else
      render :show
    end
  end

  def cancel
    load_user_report
    if @report.verified?
      @report.cancel!
      redirect_to reports_url, notice: "Arztbrief erfolgreich storniert."
    else
      render :show
    end
  end

  def destroy
    load_user_report
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

  def load_user_report
    @report = current_user.reports.find(params[:id])
  end

  def reports
    if params[:pending] == 'false'
      #current_user.reports.verified
      current_user.reports.where('updated_at > ?', Time.zone.now.beginning_of_day).order(updated_at: :desc)
    else
      current_user.reports.pending
    end
  end

  def report_params
    params.permit(:diagnosis) # TODO: Permit also other report attributes!
  end
end
