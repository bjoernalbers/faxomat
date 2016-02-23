# Interface to CUPS.
class Printer::CupsDriver
  attr_reader :printer_name, :dialout_prefix

  def initialize(opts = {})
    @dialout_prefix =
      opts.fetch(:dialout_prefix) { ENV.fetch('DIALOUT_PREFIX', nil) }
    @printer_name =
      opts.fetch(:printer_name)   { ENV.fetch('PRINTER_NAME', 'Fax') }
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
    phone = [dialout_prefix, print_job.phone].join
    Cups::PrintJob.new(print_job.path, printer_name, 'phone' => phone).tap do |job|
      job.title = print_job.title if print_job.title
    end
  end

  # Return hash of CUPS job statuses by CUPS job id.
  def cups_job_statuses
    Cups.all_jobs(printer_name).inject({}) do |memo, (cups_job_id,cups_job)|
      memo[cups_job_id] = cups_job.fetch(:state).to_s
      memo
    end
  end
end
