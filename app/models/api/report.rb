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
      :patient_sex,
      :patient_title,
      :patient_suffix,
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
      :address,
      :recipient,
      :document

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

    validates :recipient_fax_number, fax: true

    validates_format_of :patient_sex, with: /\A(m|w|u)\z/i, allow_blank: true

    before_validation :split_study_and_study_date
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

    private

    def save_records!
      ActiveRecord::Base.transaction do
        save_address!
        save_recipient!
        save_patient!
        save_report!
        save_document!
      end
    end

    def save_patient!
      @patient = Patient.find_or_create_by!(
        number:        patient_number,
        first_name:    patient_first_name,
        last_name:     patient_last_name,
        date_of_birth: patient_date_of_birth,
        #sex:           self.class.value_to_gender(patient_sex),
        sex:           Patient.sexes[self.class.value_to_gender(patient_sex)],
        title:         patient_title,
        suffix:        patient_suffix)
    end

    def save_report!
      @report ||= ::Report.new
      report.update!(
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
        clinic:     clinic)
    end

    def save_address!
      @address = Address.find_or_create_by!(
        street: recipient_street,
        zip:    recipient_zip,
        city:   recipient_city)
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

    # NOTE: I found no way to send the study date independent from the study in
    # Tomedo, which is Karteieintrag "Untersuchung" (UNT).
    # Thats why both fields are joined and must be split afterwards.
    def split_study_and_study_date
      if study_date.blank? && study && match = study.match(%r{^([0-9.-]+):\s+(.+)$})
        self.study_date, self.study = match.captures
      end
    end

    def strip_nondigits_from_fax_number
      self.recipient_fax_number =
        self.recipient_fax_number.present? ? self.recipient_fax_number.gsub(/[^0-9]/, '') : nil
    end
  end
end
