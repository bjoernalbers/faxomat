module API
  class Report
    include ActiveModel::Model

    attr_accessor :user,
      :patient_number,
      :patient_first_name,
      :patient_last_name,
      :patient_date_of_birth,
      :patient_sex,
      :patient_title,
      :patient_suffix,
      :recipient_last_name,
      :recipient_first_name,
      :recipient_salutation,
      :recipient_title,
      :recipient_suffix,
      :recipient_address,
      :recipient_zip,
      :recipient_city,
      :recipient_fax_number,
      :study,
      :study_date,
      :anamnesis,
      :diagnosis,
      :findings,
      :evaluation,
      :procedure,
      :clinic

    attr_writer :patient, :recipient, :report

    validates_presence_of :user,
      :patient_number,
      :patient_first_name,
      :patient_last_name,
      :patient_date_of_birth,
      :anamnesis,
      :evaluation,
      :procedure,
      :study,
      :study_date

    validates_format_of :patient_sex, with: /\A(m|w|u)\z/i, allow_blank: true

    validate :check_models

    def self.find(id)
      new(report: ::Report.find(id))
    end

    def self.value_to_gender(sex)
      case sex
      when /^m$/i     then :male
      when /^(w|f)$/i then :female
      end
    end

    def save!
      save ? true : raise('Speicherung fehlgeschlagen')
    end

    def save
      valid? ? report.save : false
    end

    def attributes=(hash)
      hash.each do |key, value|
        send("#{key}=", value)
      end
    end

    def id
      report.id
    end

    def patient
      @patient ||= find_or_create_patient
    end

    def recipient
      @recipient ||= find_or_create_recipient
    end

    def report
      @report ||= build_report
    end

    def username=(username)
      self.user = User.find_by(username: username)
    end

    private

    def find_or_create_patient
      Patient.find_or_create_by(patient_attributes)
    end

    def find_or_create_recipient
      Recipient.find_or_create_by(recipient_attributes)
    end

    def build_report
      rep = @report || ::Report.new
      rep.attributes = report_attributes
      rep
    end

    def patient_attributes
      {
        number:        patient_number,
        first_name:    patient_first_name,
        last_name:     patient_last_name,
        date_of_birth: patient_date_of_birth,
        sex:           self.class.value_to_gender(patient_sex),
        title:         patient_title,
        suffix:        patient_suffix
      }
    end

    def recipient_attributes
      {
        last_name:  recipient_last_name,
        first_name: recipient_first_name,
        salutation: recipient_salutation,
        title:      recipient_title,
        suffix:     recipient_suffix,
        address:    recipient_address,
        zip:        recipient_zip,
        city:       recipient_city,
        fax_number: recipient_fax_number
      }
    end

    def report_attributes
      # NOTE: Evil hack to capture study date from study.
      if study_date.blank? && match = study.match(%r{^([0-9.-]+):\s+(.+)$})
        self.study_date, self.study = match.captures
      end

      {
        patient:    patient,
        user:       user,
        recipient:  recipient,
        study:      study,
        study_date: study_date,
        anamnesis:  anamnesis,
        diagnosis:  diagnosis,
        findings:   findings,
        evaluation: evaluation,
        procedure:  procedure,
        clinic:     clinic
      }
    end

    def check_models
      %i(patient recipient report).each do |model|
        errors.add(model, 'ist ungültig') unless send(model).valid?
      end
    end
  end
end
