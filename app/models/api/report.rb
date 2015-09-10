module API
  class Report
    include ActiveModel::Model

    attr_accessor :subject,
      :content,
      :username,
      :patient_number,
      :patient_first_name,
      :patient_last_name,
      :patient_date_of_birth,
      :patient_sex,
      :patient_title,
      :patient_suffix

    attr_reader :report

    validates_presence_of :subject,
      :content,
      :username,
      :patient_number,
      :patient_first_name,
      :patient_last_name,
      :patient_date_of_birth

    validate :validate_existence_of_username

    validates_format_of :patient_sex, with: /\A(m|w|u)\z/i, allow_blank: true

    def self.value_to_gender(sex)
      case sex
      when /^m$/i     then :male
      when /^(w|f)$/i then :female
      end
    end

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

    def patient
      @patient ||= Patient.find_or_create_by(
        patient_number: patient_number,
        first_name:     patient_first_name,
        last_name:      patient_last_name,
        date_of_birth:  patient_date_of_birth,
        sex:            self.class.value_to_gender(patient_sex),
        title:          patient_title,
        suffix:         patient_suffix)
    end

    private

    def validate_existence_of_username
      unless user
        errors.add :username, 'does not exist'
      end
    end

    def user
      @user ||= User.find_by(username: username)
    end
  end
end
