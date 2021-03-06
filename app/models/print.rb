# Keeps track of print jobs.
class Print < Delivery
  belongs_to :printer, -> { with_deleted }, required: true

  validates :fax_number,
    presence: true, fax: true, if: :belongs_to_fax_printer?

  before_validation :assign_fax_number, unless: :fax_number, if: :belongs_to_fax_printer?, on: :create
  before_validation :strip_nondigits_from_fax_number, if: :fax_number
  before_create :print, unless: :job_number

  class << self
    # Updates status of active print jobs.
    def update_active
      Printer.active.find_each do |printer|
        statuses_by_job_number = driver_class(printer).statuses(printer)
        printer.prints.active.find_each do |print|
          if status = statuses_by_job_number[print.job_number]
            print.update!(status: status)
          end
        end
      end
    end

    def fake_printing?
      !!@fake_printing
    end

    def fake_printing=(true_or_false)
      @fake_printing = true_or_false
    end

    def driver_class(printer)
      if fake_printing?
        self::TestDriver
      else
        printer.class == HylafaxPrinter ? self::HylafaxDriver : self::CupsDriver
      end
    end
  end

  def self.updated_today
    where('updated_at >= ?', DateTime.current.beginning_of_day)
  end

  def self.count_by_status
    counts = group(:status).count
    Hash[Print.statuses.map { |k,v| [k.to_sym, counts.fetch(v, 0)] }]
  end

  def self.search(params)
    result = all

    if params[:title].present?
      result = result.joins(:document).where('documents.title LIKE ?', "%#{params[:title]}%")
    end

    if params[:fax_number].present?
      result = result.where(fax_number: params[:fax_number])
    end

    if params[:created_since].present?
      range = Time.zone.parse(params[:created_since])..Time.zone.now
      result = result.where(created_at: range)
    end

    if [:fax_number, :title].all? { |p| params[p].blank? }
      result = none
    end

    result
  end

  delegate :title, :path, :content_type, to: :document

  def to_s
    title
  end

  private

  def print
    driver.run ? self.job_number = driver.job_number : false
  end

  # Helper class to strip down a search query string.
  class Query
    attr_reader :query

    def initialize(query)
      @query = query
    end

    def blank?
      fax_number.nil? && names.empty?
    end

    def fax_number
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
    self.fax_number = self.document.fax_number if self.document
  end

  def strip_nondigits_from_fax_number
    self.fax_number =
      self.fax_number.present? ? self.fax_number.gsub(/[^0-9]/, '') : nil
  end

  def belongs_to_fax_printer?
    printer && printer.is_fax_printer?
  end

  def driver
    @driver ||= driver_class.new(self)
  end

  def driver_class
    if self.class.fake_printing?
      self.class::TestDriver
    else
      printer.class == HylafaxPrinter ? self.class::HylafaxDriver : self.class::CupsDriver
    end
  end
end
