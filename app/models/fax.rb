class Fax < ActiveRecord::Base
  PRINTER        = 'Fax'
  DIALOUT_PREFIX = '0'

  belongs_to :recipient
  belongs_to :patient

  has_many :deliveries, dependent: :destroy

  validates :path, presence: true
  validates :recipient, presence: true
  validates :patient, presence: true
  validates_uniqueness_of :print_job_id, allow_nil: true

  def self.aborted
    where(state: 'aborted')
  end

  def self.undelivered
    where(print_job_id: nil)
  end

  # Deliver all undelivered faxes.
  #
  # @returns [Array] Delivered faxes.
  def self.deliver
    undelivered.each(&:deliver)
  end

  # Update print job states from CUPS.
  def self.update_states
    Cups.all_jobs(PRINTER).each do |print_job_id,print_job|
      fax = find_by(print_job_id: print_job_id)
      if fax && print_job[:state]
        fax.update(state: print_job[:state].to_s) #TODO: Test updated at with same value!
      end
    end
  end

  # Deliver the fax
  def deliver
    unless self.print_job_id
      fail 'print job could not be delivered' unless print_job.print
      update(print_job_id: print_job.job_id)
    end
  end

  # @returns [String] recipient phone number
  def phone
    recipient.phone
  end

  # @returns [String] fax title
  def title
    patient.info
  end

  def to_s
    title
  end

  private

  # Initialize a new print job
  #
  # @returns [Cups::PrintJob]
  def print_job
    @print_job ||=
      Cups::PrintJob.new(path, PRINTER, {'phone' => DIALOUT_PREFIX + phone}).
      tap do |print_job|
        print_job.title = title
      end
  end
end
