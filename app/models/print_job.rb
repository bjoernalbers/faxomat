# Stores properties from actual CUPS print jobs.
class PrintJob < ActiveRecord::Base
  enum status: { active: 0, completed: 1, aborted: 2 }

  belongs_to :fax

  validates :fax, presence: true
  validates :cups_id, presence: true, uniqueness: true

  before_save :set_status
  after_save :save_fax

  private

  def set_status
    self.status =
      case cups_status
      when 'completed'          then 'completed'
      when 'aborted','canceled' then 'aborted'
      else                           'active'
      end
  end

  def save_fax
    self.fax.save
  end
end
