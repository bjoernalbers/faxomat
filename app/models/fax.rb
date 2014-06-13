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

  default_scope { order('created_at DESC') }

  def self.aborted
    where(state: 'aborted')
  end

  def self.created_today
    where('created_at >= ?', DateTime.current.beginning_of_day)
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

  # Search faxes by patient name(s) and/or date of birth.
  def self.search(q)
    query = Query.new(q)
    results = joins(:patient, :recipient)
    if query.blank?
      results = none
    else
      results = results.
        merge(Patient.by_birth_date(query.birth_date)) if query.birth_date
      results = results.merge(Recipient.by_phone(query.phone)) if query.phone
      query.names.each { |n| results = results.merge(Patient.by_name(n)) }
    end
    results
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

  # Helper class to strip down a search query string.
  class Query
    attr_reader :query

    def initialize(query)
      @query = query
    end

    def blank?
      birth_date.nil? && phone.nil? && names.empty?
    end

    def birth_date
      words.map do |word|
        begin
          Time.strptime(word, '%d.%m.%Y').to_date
        rescue ArgumentError
          nil
        end
      end.compact.first
    end

    def phone
      words.find { |word| /\A\d{4,}\Z/ =~ word }
    end

    def names
      words.select { |word| /\A[[:alpha:]]+\Z/ =~ word }
    end

    private

    def words
      query ? query.split : []
    end
  end
end
