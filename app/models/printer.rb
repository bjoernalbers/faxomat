# Create print jobs from faxes.
class Printer
  attr_reader :fax, :printer_name, :dialout_prefix

  def initialize(fax, opts = {})
    @fax            = fax
    @printer_name   = opts.fetch(:printer_name,   'Fax')
    @dialout_prefix = opts.fetch(:dialout_prefix, 0)
  end

  # Create print job and store CUPS jobs id on success.
  def print
    cups_print_job =
      Cups::PrintJob.new(fax.path, printer_name, 'phone' => phone)
    cups_print_job.title = fax.title if fax.title
    if cups_print_job.print
      fax.print_jobs.create!(cups_id: cups_print_job.job_id)
    else
      fail "could not print fax: #{fax}"
    end
  end

  private

  def phone
    [dialout_prefix, fax.phone].join
  end
end
