# Obsolete class.
class Delivery < ActiveRecord::Base
  FAX_PRINTER    = 'Fax'

  belongs_to :fax

  validates :fax, presence: true
end
