class Address < ActiveRecord::Base
  has_many :recipients

  validates_presence_of :street, :zip, :city
end
