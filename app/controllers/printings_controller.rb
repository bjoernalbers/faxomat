class PrintingsController < ApplicationController
  def create
    @report = Report.find(params[:report_id])
    @printer = Printer.find(params[:printer_id])
    @printing = Report::Printing.new(report: @report, printer: @printer)
    if @printing.save
      redirect_to @report, notice: 'Druckauftrag wird gesendet.'
    else
      redirect_to @report, alert: 'Oh Kacke! Der Druckauftrag konnte erzeugt werden :-('
    end
  end
end
