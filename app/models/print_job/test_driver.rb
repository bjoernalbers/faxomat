# A fake driver for test & development.
class PrintJob::TestDriver
  attr_reader :print_job

  class << self
    # Returns empty hash.
    def statuses(printer_name)
      {}
    end
  end

  def initialize(print_job)
    @print_job = print_job
  end

  # Does nothing and always returns true.
  def print
    true
  end

  # Returns random job id.
  def job_id
    rand(100_000..999_999)
  end
end
