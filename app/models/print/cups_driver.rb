# Interface to CUPS.
class Print::CupsDriver
  attr_reader :print

  class << self
    # Returns hash of print job statuses by job id.
    def statuses(printer)
      Cups.all_jobs(printer.name).inject({}) do |memo, (job_number,cups_job)|
        memo[job_number] = convert_status(cups_job.fetch(:state))
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

  def initialize(print)
    @print = print
  end

  # Actually print via CUPS
  def run
    cups_job.print
  end

  # Returns job_number from cups_job if valid.
  def job_number
    cups_job.job_id == 0 ? nil : cups_job.job_id
  end

  private

  def cups_job
    @cups_job ||= build_cups_job
  end

  def build_cups_job
    cups_job = if printer.is_fax_printer?
      Cups::PrintJob.new(print.path, printer.name, 'phone' => fax_number)
    else
      Cups::PrintJob.new(print.path, printer.name, 'Duplex' => 'DuplexNoTumble')
    end
    cups_job.title = print.title if print.title
    cups_job
  end

  def fax_number
    [printer.dialout_prefix, print.fax_number].join
  end

  def printer
    print.printer
  end
end
