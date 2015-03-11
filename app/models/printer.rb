# Interface to CUPS.
class Printer
  attr_reader :printer_name, :dialout_prefix

  def initialize(opts = {})
    @printer_name   = opts.fetch(:printer_name,   'Fax')
    @dialout_prefix = opts.fetch(:dialout_prefix, 0)
  end

  # Print (deliver) the fax.
  def print(fax)
    cups_job = build_cups_job(fax)
    if cups_job.print
      fax.print_jobs.create!(cups_job_id: cups_job.job_id)
    else
      fail "could not print fax: #{fax}"
    end
  end

  # Update CUPS job statuses on print jobs.
  def check(print_jobs)
    print_jobs.each do |print_job|
      cups_job_status = cups_job_statuses[print_job.cups_job_id]
      print_job.update! cups_job_status: cups_job_status
    end
  end

  private

  # Build CUPS job from fax.
  def build_cups_job(fax)
    phone = [dialout_prefix, fax.phone].join
    Cups::PrintJob.new(fax.path, printer_name, 'phone' => phone).tap do |job|
      job.title = fax.title if fax.title
    end
  end

  # Return hash of CUPS job statuses by CUPS job id.
  def cups_job_statuses
    @cups_job_statuses ||=
      Cups.all_jobs(printer_name).inject({}) do |memo, (cups_job_id,cups_job)|
        memo[cups_job_id] = cups_job.fetch(:state).to_s
        memo
      end
  end
end
