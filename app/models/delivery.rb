# Deliver and verify faxes via CUPS Fax printer.
class Delivery < ActiveRecord::Base
  FAX_PRINTER    = 'Fax'
  DIALOUT_PREFIX = '0'

  belongs_to :fax

  validates :fax, presence: true

  before_create :run!

  # Update all print job states by the corresponding states from CUPS.
  def self.update_print_job_states
    Cups.all_jobs(FAX_PRINTER).each do |print_job_id,print_job|
      delivery = find_by(print_job_id: print_job_id)
      state = print_job[:state]
      if delivery && state
        delivery.update(print_job_state: state)
      end
    end
  end

  private

  # Run the actual delivery process
  def run!
    unless print_job_id
      fail 'print job could not be delivered' unless print_job.print
      self.print_job_id = print_job.job_id
    end
  end

  # Initialize a new print job
  #
  # @returns [Cups::PrintJob]
  def print_job
    @print_job ||=
      Cups::PrintJob.new(fax.path, FAX_PRINTER, {'phone' => phone}).
      tap do |print_job|
        print_job.title = fax.title
      end
  end

  # @returns [String] fax phone number with dialout prefix
  def phone
    DIALOUT_PREFIX + fax.phone
  end
end
