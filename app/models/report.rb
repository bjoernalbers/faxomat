class Report < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :patient, required: true
  belongs_to :recipient, required: true
  has_many :faxes

  validates_presence_of :anamnesis,
    :evaluation,
    :procedure,
    :study,
    :study_date

  scope :pending, -> { where(verified_at: nil).where(canceled_at: nil) }

  def status
    if canceled_at.present?
      'canceled'
    elsif verified_at.present?
      'approved'
    else
      'pending'
    end
  end

  def pending?
    status == 'pending'
  end

  def approved?
    status == 'approved'
  end

  def canceled?
    status == 'canceled'
  end

  def approved!
    now = Time.zone.now
    update!(verified_at: now)
  end

  def canceled!
    now = Time.zone.now
    update!(canceled_at: now)
  end

  # TODO: Remove (this should not be possible!)
  def pending!
    update!(verified_at: nil, canceled_at: nil)
  end

  def subject
    "#{study} vom #{study_date.strftime('%-d.%-m.%Y')}"
  end

  def title
    patient.display_name
  end

  def deliver_as_fax
    ReportFaxer.deliver(self)
  end
end
