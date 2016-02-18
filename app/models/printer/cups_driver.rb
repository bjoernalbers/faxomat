# Interface to CUPS.
class Printer::CupsDriver
  attr_reader :printer_name, :dialout_prefix

  def initialize(opts = {})
    @dialout_prefix =
      opts.fetch(:dialout_prefix) { ENV.fetch('DIALOUT_PREFIX', nil) }
    @printer_name =
      opts.fetch(:printer_name)   { ENV.fetch('PRINTER_NAME', 'Fax') }
  end

  # Print (deliver) the fax.
  def print(fax)
    cups_job = build_cups_job(fax)
    cups_job.print ? cups_job.job_id : false
  end

  # Update CUPS job statuses on faxes.
  def check(faxes)
    statuses = cups_job_statuses
    faxes.each do |fax|
      fax.update! status: statuses[fax.cups_job_id]
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
    Cups.all_jobs(printer_name).inject({}) do |memo, (cups_job_id,cups_job)|
      memo[cups_job_id] = cups_job.fetch(:state).to_s
      memo
    end
  end
end
