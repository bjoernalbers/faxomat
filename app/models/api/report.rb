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
      :patient_suffix,
      :recipient_last_name,
      :recipient_first_name,
      :recipient_sex,
      :recipient_title,
      :recipient_suffix,
      :recipient_address,
      :recipient_zip,
      :recipient_city,
      :recipient_fax_number

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
                                 user_id: user.id,
                                 recipient_id: recipient.id)
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

    def recipient
      @recipient ||= Recipient.find_or_create_by(
        last_name:     recipient_last_name,
        first_name:    recipient_first_name,
        sex:           self.class.value_to_gender(recipient_sex),
        title:         recipient_title,
        suffix:        recipient_suffix,
        address:       recipient_address,
        zip:           recipient_zip,
        city:          recipient_city,
        fax_number_id: fax_number.id)
    end

    def fax_number
      @fax_number ||= FaxNumber.find_or_create_by(
        phone: recipient_fax_number)
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
