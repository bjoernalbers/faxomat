class Recipient < ActiveRecord::Base
  validates_presence_of :last_name

  before_validation :strip_nondigits_from_fax_number

  has_many :reports

  validates :fax_number, fax: true, if: :fax_number

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
    self.fax_number =
      self.fax_number.present? ? self.fax_number.gsub(/[^0-9]/, '') : nil
  end
end
