class Printer < ActiveRecord::Base
  has_many :print_jobs

  validates :name,
    presence: true,
    uniqueness: true
  validates :label,
    presence: true

  class << self
    # Returns distinct printers with active print jobs.
    def active
      joins(:print_jobs).
        where(id: PrintJob.active.select(:printer_id)).
        distinct
    end
  end

  def is_fax_printer?
    false
  end
end
