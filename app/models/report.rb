class Report < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :patient, required: true
  belongs_to :recipient, required: true

  has_one :document
  has_many :print_jobs, through: :document

  validates_presence_of :anamnesis,
    :evaluation,
    :procedure,
    :study,
    :study_date

  before_save :replace_carriage_returns
  before_update :check_if_updatable
  before_destroy :check_if_destroyable

  after_create :create_report_document
  after_update :update_report_document, if: :changed?

  scope :pending,  -> { where(verified_at: nil).where(canceled_at: nil) }
  scope :verified, -> { where.not(verified_at: nil).where(canceled_at: nil) }

  class << self
    def to_deliver
      verified.where(id: Document.to_deliver.select(:report_id))
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
      false
    end
  end

  def has_forbidden_changes?
    allowed_fields = %w(verified_at canceled_at updated_at)
    !pending? && !changed.all? { |c| allowed_fields.include?(c) }
  end

  def create_report_document
    to_pdf.to_file do |file|
      create_document!(title: title, file: file)
    end
  end

  def update_report_document
    to_pdf.to_file do |file|
      document.update!(title: title, file: file)
    end
  end
end
