class Patient < ActiveRecord::Base
  enum sex: { male: 0, female: 1 }

  validates_presence_of :first_name,
    :last_name,
    :date_of_birth,
    :patient_number

  before_save :strip_patient_number

  def display_name
    "#{last_name}, #{first_name} (* #{date_of_birth.strftime('%-d.%-m.%Y')})"
  end

  def to_s
    display_name
  end

  private

  def strip_patient_number
    self.patient_number = self.patient_number.strip
  end
end
