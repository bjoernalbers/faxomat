class Recipient < ActiveRecord::Base
  MINIMUM_PHONE_LENGTH = 8
  AREA_CODE_REGEX = %r{\A0[1-9]}

  has_many :faxes

  before_validation :clean_phone

  validates :phone,
    presence: true,
    uniqueness: true,
    length: {minimum: MINIMUM_PHONE_LENGTH},
    format: {with: AREA_CODE_REGEX, message: 'has no area code'}

  private

  # Strip non-digits from phone.
  def clean_phone
    self.phone = self.phone.gsub(/[^0-9]/, '') if self.phone
  end
end
