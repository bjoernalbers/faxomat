# A fake driver for test & development.
class Print::TestDriver
  attr_reader :print

  class << self
    # Returns empty hash.
    def statuses(printer_name)
      {}
    end
  end

  def initialize(print)
    @print = print
  end

  # Does nothing and always returns true.
  def run
    true
  end

  # Returns random job id.
  def job_id
    rand(100_000..999_999)
  end
end
