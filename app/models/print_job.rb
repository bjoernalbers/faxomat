# Keeps track of print jobs.
class PrintJob < ActiveRecord::Base
  enum status: { active: 0, completed: 1, aborted: 2 }

  attr_writer :phone

  belongs_to :fax_number
  belongs_to :report

  has_attached_file :document,
    path: ':rails_root/storage/:rails_env/:class/:id/:attachment/:filename'

  validates :title,
    presence: true

  validates_uniqueness_of :cups_job_id, allow_nil: true
  validates_presence_of :cups_job_id, if: :status
  validates_absence_of :cups_job_id, unless: :status

  validates_attachment :document,
    presence: true,
    content_type: { content_type: 'application/pdf' }

  validates :phone,
    presence: true,
    length: {minimum: FaxNumber::MINIMUM_PHONE_LENGTH},
    format: {with: FaxNumber::AREA_CODE_REGEX, message: 'has no area code'}

  before_save :assign_fax_number

  #NOTE: `before_save` does not work since attachments are only persisted and available after(!) save!
  #before_save :print, unless: :cups_job_id
  after_commit :print, on: :create, unless: :cups_job_id

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
    Hash[PrintJob.statuses.map { |k,v| [k.to_sym, counts.fetch(v, 0)] }]
  end

  # Update active print jobs.
  def self.check
    Printer.new.check(self.active)
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

  # TODO: Test this!
  def print
    printer.print(self)
  end

  private

  def printer
    @printer ||= Printer.new
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

  def assign_fax_number
    self.fax_number = FaxNumber.find_or_create_by!(phone: phone)
  end

  def check_if_aborted
    unless aborted?
      self.errors[:base] << 'Nur abgebrochene Druckaufträge können gelöscht werden.'
      false
    end
  end
end
