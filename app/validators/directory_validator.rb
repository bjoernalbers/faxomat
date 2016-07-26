class DirectoryValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && !File.directory?(value)
      record.errors[attribute] << (options[:message] || default_message)
    end
  end

  private

  def default_message
    'muss ein Verzeichnis auf dem Server sein'
  end
end
