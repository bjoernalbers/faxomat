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
    if cups_job.print
      Rails.logger.info 'Successfully send print job to CUPS.'
      loop do
        sleep 0.1
        job_id = cups_job.job_id
        return job_id unless job_id.zero?
        Rails.logger.warn 'SHIT: Got a zero Job ID from CUPS!'
      end
    else
      Rails.logger.warn 'Failed to send print job to CUPS.'
      false
    end
  end

  # Update CUPS job statuses on faxes.
  def check(faxes)
    statuses = cups_job_statuses
    faxes.each do |fax|
      status =
        case statuses[fax.cups_job_id]
        when 'completed'            then :completed
        when 'aborted', 'cancelled' then :aborted
        else                             :active
        end
      fax.update! status: status
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
