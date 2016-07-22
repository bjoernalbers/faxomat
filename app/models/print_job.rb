class PrintJob < ActiveRecord::Base
  belongs_to :printer,
    required: true

  validates :number,
    presence: true,
    uniqueness: true
  validates :fax_number,
    fax: true
end
