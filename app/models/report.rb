class Report < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :patient, required: true

  has_many :documents, dependent: :destroy
  has_many :prints, through: :documents
  has_many :verifications
  has_one  :cancellation

  validates_presence_of :anamnesis,
    :evaluation,
    :procedure,
    :study,
    :study_date
  validate :check_if_updatable, on: :update

  before_save :replace_carriage_returns
  before_destroy :check_if_destroyable

  #after_update :update_documents, if: :changed?
  after_commit :update_documents, on: :update # TODO: Test this!

  class << self
    def pending
      without_verification
    end

    def verified
      with_verification.without_cancellation
    end

    def canceled
      with_cancellation
    end

    def not_verified
      where('reports.id NOT IN (SELECT report_verifications.report_id FROM report_verifications) OR reports.id IN (SELECT report_cancellations.report_id FROM report_cancellations)')
    end

    def without_verification
      where.not(id: self::Verification.select(:report_id))
    end

    def with_verification
      where(id: self::Verification.select(:report_id))
    end

    def without_cancellation
      where.not(id: self::Cancellation.select(:report_id))
    end

    def with_cancellation
      where(id: self::Cancellation.select(:report_id))
    end
  end

  def status
    if cancellation.present?
      :canceled
    elsif verifications.present?
      :verified
    else
      :pending
    end
  end

  def verify!
    verifications.create!(user: user) if pending?
  end

  def cancel!
    create_cancellation!(user: user) if verified?
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

  def patient_name
    patient.try(:display_name)
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

  def physician_suffix
    user.try(:suffix)
  end

  def signature_path
    user.try(:signature_path)
  end

  def to_pdf
    ReportPdf.new(self)
  end

  def update_documents
    #documents.each { |document| document.save } # `documents.each` does not work!
    documents.find_each { |document| document.save }
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
    allowed_fields = %w(updated_at)
    !pending? && !changed.all? { |c| allowed_fields.include?(c) }
  end
end
