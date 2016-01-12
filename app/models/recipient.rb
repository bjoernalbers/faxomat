class Recipient < ActiveRecord::Base
  MINIMUM_PHONE_LENGTH = 8
  AREA_CODE_REGEX = %r{\A0[1-9]}

  validates_presence_of :last_name

  before_validation :strip_nondigits_from_fax_number

  validates :fax_number,
    #presence: true,
    #uniqueness: true,
    length: {minimum: MINIMUM_PHONE_LENGTH},
    format: {with: AREA_CODE_REGEX, message: 'has no area code'}

  def full_name
    [ title, first_name, last_name ].compact.join(' ')
  end

  def full_address
    [ full_name, suffix, address, zip_with_city ]
  end

  private

  def zip_with_city
    [ zip, city ].compact.join(' ')
  end

  def strip_nondigits_from_fax_number
    self.fax_number = self.fax_number.gsub(/[^0-9]/, '') if self.fax_number
  end
end
