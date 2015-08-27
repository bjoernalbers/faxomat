# Stores faxes.
class Fax < ActiveRecord::Base
  enum status: { active: 0, completed: 1, aborted: 2 }

  attr_writer :phone

  belongs_to :fax_number
  has_many :print_jobs, dependent: :destroy

  has_attached_file :document,
    path: ':rails_root/storage/:rails_env/:class/:id/:attachment/:filename'

  validates :title,
    presence: true

  validates_attachment :document,
    presence: true,
    content_type: { content_type: 'application/pdf' }

  validates :phone,
    presence: true,
    length: {minimum: FaxNumber::MINIMUM_PHONE_LENGTH},
    format: {with: FaxNumber::AREA_CODE_REGEX, message: 'has no area code'}

  before_save :assign_fax_number
  before_save :set_status
  before_destroy :check_if_aborted

  def self.updated_today
    where('updated_at >= ?', DateTime.current.beginning_of_day)
  end

  def self.created_last_week
    last_week = Time.zone.now - 1.week
    where('created_at >= ? AND created_at <= ?',
          last_week.beginning_of_week,
          last_week.end_of_week)
  end

  def self.count_by_status
    counts = group(:status).count
    Hash[Fax.statuses.map { |k,v| [k.to_sym, counts.fetch(v, 0)] }]
  end

  # Update active print jobs.
  def self.check
    PrintJob.update_active
  end

  def self.search(params)
    result = joins(:fax_number)

    if params[:title].present?
      result = result.where('title LIKE ?', "%#{params[:title]}%")
    end

    if params[:phone].present?
      result = result.merge(FaxNumber.by_phone(params[:phone]))
    end

    if params[:created_since].present?
      range = Time.zone.parse(params[:created_since])..Time.zone.now
      result = result.where(created_at: range)
    end

    if [:phone, :title].all? { |p| params[p].blank? }
      result = none
    end

    result
  end

  # Deliver the fax.
  def deliver
    Printer.new.print(self)
  end

  def phone
    @phone ? @phone.gsub(/[^0-9]/, '') : fax_number.try(:phone)
  end

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

  def assign_fax_number
    self.fax_number = FaxNumber.find_or_create_by!(phone: phone)
  end

  def set_status
    self.status =
      case
      when print_jobs.empty?             then nil
      when print_jobs.active.present?    then :active
      when print_jobs.completed.present? then :completed
      else                                    :aborted
      end
  end

  def check_if_aborted
    unless aborted?
      self.errors[:base] << 'Can only delete aborted faxes.'
      false
    end
  end
end
