class AttendancesController < ApplicationController
  def new
    attendance = Attendance.new(patient: params[:patient])
    pdf = AttendancePdf.new(attendance)
    send_data pdf.render, filename: 'Anwesenheitsbescheinigung.pdf', type: 'application/pdf', disposition: :inline
  end
end
