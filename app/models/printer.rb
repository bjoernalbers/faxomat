# Generic printer
class Printer
  class << self
    # Returns CUPS driver if not set.
    def default_driver_class
      @default_driver_class || Printer::CupsDriver
    end

    # Set default driver.
    def default_driver_class=(driver_class)
      @default_driver_class = driver_class
    end
  end

  attr_reader :printer_name, :dialout_prefix, :driver_class

  def initialize(opts = {})
    @driver_class = opts.fetch(:driver_class, self.class.default_driver_class)
  end

  # Print the print job.
  def print(fax)
    fax = Fax.find(fax.id)
    cups_job_id = driver.print(fax)
    fax.update cups_job_id: cups_job_id, status: :active
  end

  # Update print jobs.
  def check(print_jobs)
    driver.check(print_jobs)
  end

  private

  def driver
    @driver ||= driver_class.new
  end
end
