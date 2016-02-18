# A printer that does not print (for testing / development).
class Printer::TestDriver
  def initialize(opts = {})
  end

  # Returns just random number.
  def print(print_job)
    rand(100_000..999_999)
  end

  # Does not perform any checks.
  def check(print_jobs)
  end
end
