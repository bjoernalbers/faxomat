class FaxValidator < ActiveModel::EachValidator
  MINIMUM_PHONE_LENGTH = 8
  AREA_CODE_REGEX = %r{\A0[1-9]}

  def validate_each(record, attribute, value)
    if value.blank? || is_too_short?(value) || has_no_area_code?(value)
      record.errors[attribute] << (options[:message] || default_message)
    end
  end

  private

  def is_too_short?(fax)
    fax.length < MINIMUM_PHONE_LENGTH
  end

  def has_no_area_code?(fax)
    !fax.match(AREA_CODE_REGEX)
  end

  def default_message
    'ist keine gültige nationale Faxnummer mit Vorwahl'
  end
end
