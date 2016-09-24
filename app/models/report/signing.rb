class Report::Signing < ActiveRecord::Base
  belongs_to :report, required: true
  belongs_to :user, required: true

  validates :user, uniqueness: {
    scope: :report, message: 'hat Bericht bereits unterschrieben' }

  before_destroy :check_report_is_destroyable

  delegate :signature_path, :full_name, :suffix, to: :user

  def destroyable_by?(user)
    self.user == user && destroyable?
  end

  def destroyable?
    report.pending?
  end

  private

  def check_report_is_destroyable
    unless destroyable?
      errors[:report] << 'ist bereits vidiert oder storniert'
      false
    end
  end
end
