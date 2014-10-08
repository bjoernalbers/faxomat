class Fax::Deliverer
  PRINTER = 'Fax'

  attr_reader :fax

  class << self
    # Deliver all deliverable faxes.
    def deliver
      deliverable.each { |fax| fax.deliver }
    end

    # Returns deliverable and recently created faxes.
    def deliverable
      Fax.
        where('print_job_id IS NULL OR state = "aborted"').
        where('created_at >= ?', DateTime.current.beginning_of_day - 4.days).
        order('created_at')
    end

    # Check deliveries.
    def check
      Cups.all_jobs(PRINTER).each do |print_job_id,print_job|
        state = print_job[:state].to_s
        fax = Fax.find_by(print_job_id: print_job_id)
        if fax && fax.state.to_s != state
          fax.update(state: state)
        end
      end
    end
  end

  def initialize(fax)
    @fax = fax
  end

  # Deliver the fax when deliverable.
  def deliver
    deliver! if deliverable?
  end

  private

  # Returns true if the fax is deliverable, otherwise false.
  def deliverable?
    fax.print_job_id.nil? || fax.state.to_s == 'aborted'
  end

  # Actually deliver the fax.
  def deliver!
    fail 'print job could not be delivered' unless print_job.print
    fax.update(print_job_id: print_job.job_id)
  end

  # Returns a new print job
  def print_job
    @print_job ||=
      Cups::PrintJob.new(fax.path, PRINTER, 'phone' => phone).tap do |job|
        job.title = fax.title
      end
  end

  # Returns dialout prefix + fax phone.
  def phone
    [Rails.application.config.dialout_prefix, fax.phone].join
  end
end
