class FaxValidator < ActiveModel::EachValidator
  MINIMUM_PHONE_LENGTH = 8
  AREA_CODE_REGEX = %r{\A0[1-9]}

  def validate_each(record, attribute, value)
    if value.present? && has_no_area_code?(value)
      record.errors[attribute] << (options[:message] || default_message)
    end
  end

  private

  def has_no_area_code?(fax)
    fax.length < MINIMUM_PHONE_LENGTH || !fax.match(AREA_CODE_REGEX)
  end

  def default_message
    'ist keine gültige nationale Faxnummer mit Vorwahl'
  end
end
