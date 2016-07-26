class Path < ActiveRecord::Type::Value
  def type_cast_for_database(value)
    value.to_s
  end

  private

  def cast_value(value)
    ::Pathname.new(value.to_s)
  end
end
