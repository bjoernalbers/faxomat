class Recipient < ActiveRecord::Base
  enum sex: { male: 0, female: 1 }

  validates_presence_of :last_name

  belongs_to :fax_number
end
