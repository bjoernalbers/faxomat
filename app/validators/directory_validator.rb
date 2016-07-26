class DirectoryValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if value.present? && !File.directory?(value)
      record.errors[attribute] << (options[:message] || default_message)
    end
  end

  private

  def default_message
      'must be a directory'
  end
end
