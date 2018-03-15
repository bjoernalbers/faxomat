module API
  class Report
    include ActiveModel::Model
    include ActiveModel::Validations::Callbacks

    # Required for translating model names and their attributes
    # See: http://stackoverflow.com/questions/8835215/how-to-handle-translations-for-an-activemodel
    class << self
      def i18n_scope
        :activerecord
      end
    end

    attr_accessor :user,
      :patient_number,
      :patient_first_name,
      :patient_last_name,
      :patient_date_of_birth,
      :patient_title,
      :patient_suffix,
      :patient_street,
      :patient_zip,
      :patient_city,
      :recipient_last_name,
      :recipient_first_name,
      :recipient_salutation,
      :recipient_title,
      :recipient_suffix,
      :recipient_street,
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
      :clinic,
      :report

    attr_reader :patient,
      :patient_sex,
      :patient_address,
      :patient_recipient,
      :patient_document,
      :address,
      :recipient,
      :document,
      :send_report_to_patient

    validates_presence_of :user,
      :patient_number,
      :patient_first_name,
      :patient_last_name,
      :patient_date_of_birth,
      :recipient_last_name,
      :recipient_street,
      :recipient_zip,
      :recipient_city,
      :study,
      :study_date,
      :anamnesis,
      :evaluation,
      :procedure

    validates_presence_of :patient_street, :patient_zip, :patient_city,
      if: :send_report_to_patient

    validates :recipient_fax_number, fax: true

    before_validation :strip_nondigits_from_fax_number

    delegate :id, :persisted?, to: :report, allow_nil: true

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
      valid? ? (save_records!; true) : false
    rescue ActiveRecord::ActiveRecordError
      false
    end

    def attributes=(hash)
      hash.each do |key, value|
        send("#{key}=", value)
      end
    end

    def username=(username)
      self.user = User.find_by(username: username)
    end

    def patient_sex=(value)
      @patient_sex =
        case value
        when 'w', 'W', 'f', 'F' then Patient.sexes[:female]
        when 'm', 'M'           then Patient.sexes[:male]
        else                         nil
        end
    end

    def send_report_to_patient=(value)
      @send_report_to_patient =
        ActiveRecord::Type::Boolean.new.type_cast_from_database(value)
    end

    private

    def save_records!
      ActiveRecord::Base.transaction do
        save_patient!
        save_report!
        save_address!
        save_recipient!
        save_document!
        if send_report_to_patient
          save_patient_address!
          save_patient_recipient!
          save_patient_document!
        end
      end
    end

    def save_patient!
      @patient = Patient.find_or_create_by!(
        number:        patient_number,
        first_name:    patient_first_name,
        last_name:     patient_last_name,
        date_of_birth: patient_date_of_birth,
        sex:           patient_sex,
        title:         patient_title,
        suffix:        patient_suffix)
    end

    def save_report!
      @report ||= ::Report.new
      report.update!(
        patient:    patient,
        user:       user,
        study:      study,
        study_date: study_date,
        anamnesis:  anamnesis,
        diagnosis:  diagnosis,
        findings:   findings,
        evaluation: evaluation,
        procedure:  procedure,
        clinic:     clinic)
    end

    def save_address!
      @address = Address.find_or_create_by!(
        street: recipient_street,
        zip:    recipient_zip,
        city:   recipient_city)
    end

    def save_patient_address!
      @patient_address = Address.find_or_create_by!(
        street: patient_street,
        zip:    patient_zip,
        city:   patient_city)
    end

    def save_patient_recipient!
      @patient_recipient = Recipient.find_or_create_by!(
        last_name:  patient_last_name,
        first_name: patient_first_name,
        title:      patient_title,
        suffix:     patient_suffix,
        address:    patient_address)
    end

    def save_recipient!
      @recipient = Recipient.find_or_create_by!(
        last_name:  recipient_last_name,
        first_name: recipient_first_name,
        salutation: recipient_salutation,
        title:      recipient_title,
        suffix:     recipient_suffix,
        fax_number: recipient_fax_number,
        address:    address)
    end

    def save_document!
      @document = Document.find_or_create_by!(report: report, recipient: recipient)
    end

    def save_patient_document!
      @patient_document = Document.find_or_create_by!(report: report, recipient: patient_recipient)
    end

    def strip_nondigits_from_fax_number
      self.recipient_fax_number =
        self.recipient_fax_number.present? ? self.recipient_fax_number.gsub(/[^0-9]/, '') : nil
    end
  end
end
