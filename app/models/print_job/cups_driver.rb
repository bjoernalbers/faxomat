# Interface to CUPS.
class PrintJob::CupsDriver
  attr_reader :print_job

  class << self
    # Returns hash of print job statuses by job id.
    def statuses(printer_name)
      Cups.all_jobs(printer_name).inject({}) do |memo, (job_id,cups_job)|
        memo[job_id] = convert_status(cups_job.fetch(:state))
        memo
      end
    end

    private

    def convert_status(status)
      case status.to_sym
      when :completed            then :completed
      when :aborted, :cancelled  then :aborted
      else                            :active
      end
    end
  end

  def initialize(print_job)
    @print_job = print_job
  end

  # Print (deliver) the print_job.
  def print
    cups_job.print
  end

  # Returns job_id from cups_job if valid.
  def job_id
    cups_job.job_id == 0 ? nil : cups_job.job_id
  end

  private

  def cups_job
    @cups_job ||= build_cups_job
  end

  def build_cups_job
    cups_job = if printer.is_fax_printer?
      Cups::PrintJob.new(print_job.path, printer.name, 'phone' => fax_number)
    else
      Cups::PrintJob.new(print_job.path, printer.name)
    end
    cups_job.title = print_job.title if print_job.title
    cups_job
  end

  def fax_number
    [printer.dialout_prefix, print_job.fax_number].join
  end

  def printer
    print_job.printer
  end
end
