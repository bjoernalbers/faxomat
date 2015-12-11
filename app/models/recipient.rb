class Recipient < ActiveRecord::Base
  validates_presence_of :last_name

  belongs_to :fax_number

  def full_name
    [ title, first_name, last_name ].compact.join(' ')
  end

  def full_address
    [ full_name, suffix, address, zip_with_city ]
  end

  def fax_number_string
    fax_number.to_s
  end

  private

  def zip_with_city
    [ zip, city ].compact.join(' ')
  end
end
