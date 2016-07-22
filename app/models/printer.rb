class Printer < ActiveRecord::Base
  has_many :prints

  validates :name,
    presence: true,
    uniqueness: true
  validates :label,
    presence: true

  class << self
    # Returns distinct printers with active print jobs.
    def active
      joins(:prints).
        where(id: Print.active.select(:printer_id)).
        distinct
    end
  end

  def is_fax_printer?
    false
  end
end
