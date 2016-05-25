class Report < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :patient, required: true
  belongs_to :recipient, required: true
  belongs_to :document, dependent: :destroy

  has_many :print_jobs, through: :document

  validates_presence_of :anamnesis,
    :evaluation,
    :procedure,
    :study,
    :study_date
  validates_uniqueness_of :document_id, allow_nil: true
  validate :check_if_updatable, on: :update

  before_save :replace_carriage_returns
  before_destroy :check_if_destroyable

  before_create :create_report_document
  before_update :update_report_document, if: :changed?

  class << self
    def pending
      where('verified_at IS NULL')
    end

    def verified
      where('verified_at IS NOT NULL AND canceled_at IS NULL')
    end

    def canceled
      where('canceled_at IS NOT NULL')
    end

    def not_verified
      where('verified_at IS NULL OR canceled_at IS NOT NULL')
    end

    # TODO: Remove(?)!
    def to_deliver
      verified.where(document_id: Document.to_deliver.select(:id))
    end
  end

  def status
    if canceled_at.present?
      :canceled
    elsif verified_at.present?
      :verified
    else
      :pending
    end
  end

  def status=(attr)
    case attr.to_sym
    when :verified
      self.verified_at = Time.zone.now if pending?
    when :canceled
      self.canceled_at = Time.zone.now if verified?
    end
  end

  %i(pending verified canceled).each do |method_name|
    define_method("#{method_name}?") do
      status == method_name
    end
  end
  alias_method :deletable?, :pending?
  alias_method :include_signature?, :verified?

  def subject
    "#{study} vom #{study_date.strftime('%-d.%-m.%Y')}"
  end

  def title
    patient.display_name
  end

  def deliver_as_fax
    if printer = FaxPrinter.default
      if recipient_fax_number.present? # TODO: Move this into Printing-model!
        Report::Printing.new(report: self, printer: printer).save
      else
        false
      end
    else
      false
    end
  end

  def to_deliver?
    verified? && document.try(:to_deliver?)
  end

  def recipient_fax_number
    recipient.try(:fax_number)
  end

  def patient_name
    patient.try(:display_name)
  end

  def recipient_name
    recipient.try(:full_name)
  end

  def recipient_address
    recipient.try(:full_address)
  end

  def salutation
    recipient.try(:salutation) || 'Sehr geehrte Kollegen,'
  end

  def report_date
    created_at.strftime('%-d.%-m.%Y') if created_at
  end

  def valediction
    'Mit freundlichen Grüßen'
  end

  def physician_name
    user.try(:full_name)
  end

  def signature_path
    user.try(:signature_path)
  end

  def to_pdf
    ReportPdf.new(self)
  end

  private

  # NOTE: Tomedo somehow sends both carriage return and newlines. We're
  # replacing all carriage returns with new lines since they look weird in PDF
  # documents.
  def replace_carriage_returns
    %i(anamnesis diagnosis findings evaluation procedure).each do |attr|
      self[attr].gsub!("\r", "\n") if self[attr].present?
    end
  end

  def check_if_destroyable
    unless pending?
      errors.add(:base, 'Arztbrief darf nicht mehr gelöscht werden!')
      false
    end
  end

  def check_if_updatable
    if has_forbidden_changes?
      errors.add(:base, 'Arztbrief darf nicht mehr verändert werden!')
    end
  end

  def has_forbidden_changes?
    allowed_fields = %w(verified_at canceled_at updated_at)
    !pending? && !changed.all? { |c| allowed_fields.include?(c) }
  end

  def create_report_document
    unless self.document # TODO: Test this condition!
      to_pdf.to_file do |file|
        self.document = Document.create!(title: title,
                                         file: file,
                                         recipient: recipient)
      end
    end
  end

  def update_report_document
    to_pdf.to_file do |file|
      self.document.update!(title: title,
                            file: file,
                            recipient: recipient)
    end
  end
end
