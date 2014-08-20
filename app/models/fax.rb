class Fax < ActiveRecord::Base
  PRINTER        = 'Fax'
  DIALOUT_PREFIX = '0'

  attr_writer :phone

  belongs_to :recipient

  has_many :deliveries, dependent: :destroy

  has_attached_file :document

  validates_uniqueness_of :print_job_id, allow_nil: true
  validates :phone,
    presence: true,
    length: {minimum: Recipient::MINIMUM_PHONE_LENGTH},
    format: {with: Recipient::AREA_CODE_REGEX, message: 'has no area code'}
  validates_attachment :document,
    content_type: { content_type: 'application/pdf' }

  before_save :assign_recipient

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

  def self.search(q)
    query = Query.new(q)
    results = joins(:recipient)
    if query.blank?
      results = none
    else
      results = results.merge(Recipient.by_phone(query.phone)) if query.phone
      query.names.each do |name|
        results = results.where('title LIKE ?', "%#{name}%")
      end
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

  def phone
    @phone ? @phone.gsub(/[^0-9]/, '') : recipient.try(:phone)
  end

  # @returns [String] fax title
  #def title
    #'' # TODO: Set better default title!
  #end

  def to_s
    title
  end

  private

  # Initialize a new print job
  #
  # @returns [Cups::PrintJob]
  def print_job
    @print_job ||=
      Cups::PrintJob.new(document.path, PRINTER, {'phone' => full_phone}).
      tap do |print_job|
        print_job.title = title
      end
  end

  # @returns [String] Dialout prefix + recipient phone.
  def full_phone
    [Rails.application.config.dialout_prefix, phone].join
  end

  # Helper class to strip down a search query string.
  class Query
    attr_reader :query

    def initialize(query)
      @query = query
    end

    def blank?
      phone.nil? && names.empty?
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

  private

  def assign_recipient
    self.recipient = Recipient.find_or_create_by!(phone: phone)
  end
end
