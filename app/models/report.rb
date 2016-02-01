class Report < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :patient, required: true
  belongs_to :recipient, required: true
  has_many :faxes
  has_one :letter

  validates_presence_of :anamnesis,
    :evaluation,
    :procedure,
    :study,
    :study_date

  scope :pending,  -> { where(verified_at: nil).where(canceled_at: nil) }
  scope :verified, -> { where.not(verified_at: nil).where(canceled_at: nil) }
  scope :not_delivered, -> { verified.without_letter.without_completed_fax }
  # Taken from: http://stackoverflow.com/questions/5319400/want-to-find-records-with-no-associated-records-in-rails-3
  scope :without_letter, -> { includes(:letter).where(letters: { report_id: nil }) }
  scope :without_completed_fax, -> { where.not(id: Fax.completed.select(:report_id)) }

  validate :status_change_is_allowed
  validates :status, inclusion: { in: %i(pending verified canceled),
        message: "%{value} is not a valid status" }

  before_save :set_verified_at
  before_save :set_canceled_at

  before_destroy :allow_destroy_only_when_pending

  def status
    @status ||= internal_status
  end

  def status=(attr)
    @status = attr.to_sym unless attr.blank?
  end

  # TODO: Refactor this!
  def status_change_is_allowed
    if status == :canceled and internal_status == :pending
      errors.add(:status, 'can not be changed from :pending to :canceled')
    elsif status == :pending and internal_status == :verified
      errors.add(:status, 'can not be changed from :verified to :pending')
    elsif status == :pending and internal_status == :canceled
      errors.add(:status, 'can not be changed from :canceled to :pending')
    elsif status == :verified and internal_status == :canceled
      errors.add(:status, 'can not be changed from :canceled to :verified')
    end
  end

  # TODO: Refactor these!
  def pending?
    status == :pending
  end
  def verified?
    status == :verified
  end
  def canceled?
    status == :canceled
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

  def delivered?
    letter.present? || faxes.completed.present?
  end

  private

  def internal_status
    if canceled_at.present?
      :canceled
    elsif verified_at.present?
      :verified
    else
      :pending
    end
  end

  def set_verified_at
    self.verified_at ||= Time.zone.now if verified?
  end

  def set_canceled_at
    self.canceled_at ||= Time.zone.now if canceled?
  end

  def allow_destroy_only_when_pending
    unless pending?
      errors.add(:base, 'Ein vidierter oder stornierter Arztbrief kann nicht gelöscht werden!')
      false
    end
  end
end
