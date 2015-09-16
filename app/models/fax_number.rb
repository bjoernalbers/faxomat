class FaxNumber < ActiveRecord::Base
  MINIMUM_PHONE_LENGTH = 8
  AREA_CODE_REGEX = %r{\A0[1-9]}

  has_many :faxes

  before_validation :strip_nondigits

  validates :phone,
    presence: true,
    uniqueness: true,
    length: {minimum: MINIMUM_PHONE_LENGTH},
    format: {with: AREA_CODE_REGEX, message: 'has no area code'}

  def self.by_phone(phone)
    where('fax_numbers.phone LIKE ?', "%#{phone}%")
  end

  def to_s
    phone
  end

  def fax_number
    phone
  end

  private

  def strip_nondigits
    self.phone = self.phone.gsub(/[^0-9]/, '') if self.phone
  end
end
