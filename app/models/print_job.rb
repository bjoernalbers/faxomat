# Stores properties from actual CUPS print jobs.
class PrintJob < ActiveRecord::Base
  enum status: { active: 0, completed: 1, aborted: 2 }

  belongs_to :fax

  validates :fax, presence: true
  validates :cups_job_id, presence: true, uniqueness: true

  before_save :set_status
  after_save :save_fax

  # Update active print jobs.
  def self.update_active
    Printer.new.check(self.active)
  end

  private

  def set_status
    self.status =
      case cups_job_status
      when 'completed'            then :completed
      when 'aborted', 'cancelled' then :aborted
      else                             :active
      end
  end

  def save_fax
    self.fax.save
  end
end
