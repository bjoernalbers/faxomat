# Interface to CUPS.
class Printer
  attr_reader :printer_name, :dialout_prefix

  def initialize(opts = {})
    @printer_name   = opts.fetch(:printer_name,   'Fax')
    @dialout_prefix = opts.fetch(:dialout_prefix, 0)
  end

  # Create print job from fax.
  def print(fax)
    cups_print_job = build_cups_print_job(fax)
    if cups_print_job.print
      fax.print_jobs.create!(cups_id: cups_print_job.job_id)
    else
      fail "could not print fax: #{fax}"
    end
  end

  # Update CUPS status on print jobs.
  def check(print_jobs)
    print_jobs.each do |print_job|
      print_job.update! cups_status: cups_statuses[print_job.cups_id]
    end
  end

  private

  # Build CUPS print job from fax.
  def build_cups_print_job(fax)
    phone = [dialout_prefix, fax.phone].join
    Cups::PrintJob.new(fax.path, printer_name, 'phone' => phone).tap do |job|
      job.title = fax.title if fax.title
    end
  end

  # Return CUPS statuses by CUPS id.
  def cups_statuses
    @cups_statuses ||=
      Cups.all_jobs(printer_name).inject({}) do |result, (cups_id,properties)|
        result[cups_id] = properties.fetch(:state).to_s
        result
      end
  end
end
