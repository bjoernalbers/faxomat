class Report::Release < ActiveRecord::Base
  belongs_to :report, required: true
  belongs_to :user, required: true

  validates :report, uniqueness: { message: 'wurde bereits freigegeben' }
  validate :user_is_authorized, if: :user

  after_commit :update_report_documents

  class << self
    def canceled
      where.not(canceled_at: nil)
    end

    def uncanceled
      where(canceled_at: nil)
    end
  end

  def cancel!
    update!(canceled_at: Time.zone.now) unless canceled?
  end

  def canceled?
    self[:canceled_at].present?
  end

  private

  def user_is_authorized
    unless user.can_release_reports?
      errors[:user] << 'darf nicht Berichte freigeben'
    end
  end

  def update_report_documents
    # NOTE: Reloading report is required to refresh the (cached) status.
    report.reload.update_documents
  end
end
