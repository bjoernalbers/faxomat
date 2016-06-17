class Recipient < ActiveRecord::Base
  belongs_to :address
  has_many :reports

  before_validation :strip_nondigits_from_fax_number

  validates :fax_number, fax: true

  delegate :street, :zip, :city, to: :address, allow_nil: true

  def salutation
    self[:salutation].present? ? self[:salutation] : 'Sehr geehrte Kollegen,'
  end

  def full_name
    [ title, first_name, last_name ].compact.join(' ')
  end

  def full_address
    address.present? ? [ full_name, suffix, street, zip_with_city ] : [ full_name, suffix ]
  end

  private

  def zip_with_city
    [ zip, city ].compact.join(' ')
  end

  def strip_nondigits_from_fax_number
    self.fax_number =
      self.fax_number.present? ? self.fax_number.gsub(/[^0-9]/, '') : nil
  end
end
