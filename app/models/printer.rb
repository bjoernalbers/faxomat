class Printer < ActiveRecord::Base
  has_many :print_jobs

  validates :name,
    presence: true,
    uniqueness: true
  validates :label,
    presence: true

  class << self
    # Returns CUPS driver if not set.
    def default_driver_class
      @default_driver_class || Printer::CupsDriver
    end

    # Set default driver.
    def default_driver_class=(driver_class)
      @default_driver_class = driver_class
    end

    def update_active_print_jobs
      find_each { |printer| printer.update_active_print_jobs }
    end

    def fax_printer
      find_by(name: 'Fax')
    end
  end

  def update_active_print_jobs
    driver.check(active_print_jobs)
  end

  # Print print job.
  def print(print_job)
    print_job = PrintJob.find(print_job.id)
    cups_job_id = driver.print(print_job)
    print_job.update cups_job_id: cups_job_id, status: :active
  end

  def driver
    driver_class.new(printer_name: name, dialout_prefix: dialout_prefix)
  end

  def driver_class
    self.class.default_driver_class
  end

  private

  def active_print_jobs
    print_jobs.active.all
  end
end
