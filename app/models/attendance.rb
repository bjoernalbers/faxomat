class Attendance
  include ActiveModel::Model

  attr_accessor :patient

  def certificate
    "Der Patient / die Patientin #{patient} war in unserer Praxis, juhu!"
  end
end
