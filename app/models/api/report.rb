module API
  class Report
    include ActiveModel::Model

    attr_accessor :subject,
      :content,
      :username,
      :patient_number,
      :patient_first_name,
      :patient_last_name,
      :patient_date_of_birth

    attr_reader :report

    validates_presence_of :subject,
      :content,
      :username,
      :patient_number,
      :patient_first_name,
      :patient_last_name,
      :patient_date_of_birth

    validate :validate_existence_of_username

    def save
      if valid?
        @report ||= ::Report.new(subject: subject,
                                 content: content,
                                 patient_id: patient.id,
                                 user_id: user.id)
        report.save!
        true
      else
        false
      end
    end

    def save!
      raise "Could not save stuff!" unless save
    end

    def id
      report.id
    end

    private

    def validate_existence_of_username
      unless user
        errors.add :username, 'does not exist'
      end
    end

    # TODO: Handle patient with existing patient number!
    def patient
      @patient ||= Patient.create(
        patient_number: patient_number,
        first_name:     patient_first_name,
        last_name:      patient_last_name,
        date_of_birth:  patient_date_of_birth)
    end

    def user
      @user ||= User.find_by(username: username)
    end
  end
end
