# Persist fax jobs (=JSON files) into the database.
class Job
  include ActiveModel::Model

  attr_accessor :phone, :path, :patient_first_name, :patient_last_name,
    :patient_date_of_birth

  # New instance from JSON job file.
  #
  # @returns [Job] New job from JSON file.
  def self.from_json(json)
    new(JSON.parse(json))
  end

  # Persist data by saving all objects to the database.
  #
  # @returns [Boolean] true when all objects could be saved, otherwise false
  def save
    [recipient, patient, fax].all? { |o| o.save }
  end

  private

  # @returns [Recipient] Existing or new recipient
  def recipient
    @recipient ||= Recipient.find_or_initialize_by(phone: phone)
  end

  # @returns [Patient] Existing or new patient
  def patient
    @patient ||= Patient.find_or_initialize_by(
      first_name: patient_first_name,
      last_name: patient_last_name,
      date_of_birth: patient_date_of_birth)
  end

  # @returns [Fax] New fax
  def fax
    @fax ||= Fax.new(path: path, recipient: recipient, patient: patient)
  end
end
