class Fax < ActiveRecord::Base
  attr_writer :phone

  belongs_to :recipient

  has_many :deliveries, dependent: :destroy

  has_attached_file :document,
    path: ':rails_root/storage/:rails_env/:class/:id/:attachment/:filename'

  validates_attachment :document,
    presence: true,
    content_type: { content_type: "application/pdf" }

  validates_uniqueness_of :print_job_id, allow_nil: true
  validates :phone,
    presence: true,
    length: {minimum: Recipient::MINIMUM_PHONE_LENGTH},
    format: {with: Recipient::AREA_CODE_REGEX, message: 'has no area code'}
  validates_attachment :document,
    content_type: { content_type: 'application/pdf' }

  before_save :assign_recipient

  after_commit :deliver, :on => :create

  def self.undeliverable
    where(state: 'undeliverable')
  end

  def self.updated_today
    where('updated_at >= ?', DateTime.current.beginning_of_day)
  end

  # Deliver all deliverable faxes.
  def self.deliver
    Deliverer.deliver
  end

  # Check deliveries.
  def self.check
    Deliverer.check
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

  # Deliver the fax.
  def deliver
    Deliverer.new(self).deliver
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

  # Returns the document path
  def path
    document.path
  end

  private

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
