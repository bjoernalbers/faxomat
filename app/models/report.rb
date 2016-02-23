class Report < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :patient, required: true
  belongs_to :recipient, required: true
  has_many :print_jobs
  has_one :letter

  validates_presence_of :anamnesis,
    :evaluation,
    :procedure,
    :study,
    :study_date

  scope :pending,  -> { where(verified_at: nil).where(canceled_at: nil) }
  scope :verified, -> { where.not(verified_at: nil).where(canceled_at: nil) }
  scope :unsent, -> { verified.without_letter.without_completed_print_job }
  # Taken from: http://stackoverflow.com/questions/5319400/want-to-find-records-with-no-associated-records-in-rails-3
  scope :without_letter, -> { includes(:letter).where(letters: { report_id: nil }) }
  scope :without_completed_print_job, -> { where.not(id: PrintJob.completed.select(:report_id)) }

  before_destroy :allow_destroy_only_when_pending

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

  def subject
    "#{study} vom #{study_date.strftime('%-d.%-m.%Y')}"
  end

  def title
    patient.display_name
  end

  def deliver_as_fax
    ReportFaxer.deliver(self)
  end

  def sent?
    letter.present? || print_jobs.completed.present?
  end

  private

  def allow_destroy_only_when_pending
    unless pending?
      errors.add(:base, 'Ein vidierter oder stornierter Arztbrief kann nicht gelöscht werden!')
      false
    end
  end
end
