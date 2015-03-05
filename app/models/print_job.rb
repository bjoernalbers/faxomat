# Stores properties from actual CUPS print jobs.
class PrintJob < ActiveRecord::Base
  belongs_to :fax

  validates :fax, presence: true
  validates :cups_id, presence: true, uniqueness: true
end
