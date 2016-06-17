class PrintingsController < ApplicationController
  before_action :load_report

  def new
    build_printing
  end

  def create
    build_printing
    @printing.printer_id =
      params[:report_printing][:printer_id] if params[:report_printing]
    if @printing.save
      redirect_to @report, notice: 'Druckauftrag wird gesendet.'
    else
      redirect_to @report, alert: 'Oh Kacke! Der Druckauftrag konnte erzeugt werden :-('
    end
  end

  private

  def build_printing
    @printing = Report::Printing.new(report: @report)
  end

  def load_report
    @report = Report.find(params[:report_id])
  end
end
