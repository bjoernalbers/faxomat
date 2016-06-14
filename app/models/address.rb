class Address < ActiveRecord::Base
  validates_presence_of :street, :zip, :city
end
