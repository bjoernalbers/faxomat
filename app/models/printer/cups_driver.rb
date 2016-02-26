# Interface to CUPS.
class Printer::CupsDriver
  attr_reader :printer

  def initialize(printer)
    @printer = printer
  end

  # Print (deliver) the print_job.
  def print(print_job)
    cups_job = build_cups_job(print_job)
    cups_job.print ? cups_job.job_id : false
  end

  # Update CUPS job statuses on print_jobs.
  def check(print_jobs)
    statuses = cups_job_statuses
    print_jobs.each do |print_job|
      status =
        case statuses[print_job.cups_job_id]
        when 'completed'            then :completed
        when 'aborted', 'cancelled' then :aborted
        else                             :active
        end
      print_job.update! status: status
    end
  end

  private

  # Build CUPS job from print_job.
  def build_cups_job(print_job)
    fax_number = [printer.dialout_prefix, print_job.fax_number].join
    cups_job = if printer.is_fax_printer?
      Cups::PrintJob.new(print_job.path, printer.name, 'phone' => fax_number)
    else
      Cups::PrintJob.new(print_job.path, printer.name)
    end
    cups_job.title = print_job.title if print_job.title
    cups_job
  end

  # Return hash of CUPS job statuses by CUPS job id.
  def cups_job_statuses
    Cups.all_jobs(printer.name).inject({}) do |memo, (cups_job_id,cups_job)|
      memo[cups_job_id] = cups_job.fetch(:state).to_s
      memo
    end
  end
end
