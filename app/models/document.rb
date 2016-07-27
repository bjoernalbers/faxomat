class Document < ActiveRecord::Base
  belongs_to :recipient, required: true
  belongs_to :report
  has_many :prints
  has_many :deliveries
  has_many :exports

  has_attached_file :file,
    path: ':rails_root/storage/:rails_env/:class/:id/:attachment/:filename'

  validates_presence_of :title, unless: :report_id?
  validates_attachment_presence :file, unless: :report_id?
  validates_attachment_content_type :file, content_type: 'application/pdf'

  around_save :assign_report_attributes, if: :report_id?
  after_commit :deliver, on: [:update, :create], if: :to_deliver? # TODO: Test this!

  class << self
    def delivered_today
      includes(:deliveries).
        where('deliveries.created_at > ?', Time.zone.now.beginning_of_day).
        order('deliveries.created_at DESC').distinct
    end

    def to_deliver
      released_for_delivery.without_active_or_completed_delivery
    end

    def released_for_delivery
      #where.not(report_id: Report.not_verified.select(:id)) # NOTE: Does not work in production and development but in test?!
      report_id = arel_table[:report_id]
      report_id_is_null = report_id.eq(nil)
      report_id_from_verified_report = report_id.not_in(Report.not_verified.pluck(:id))
      where(report_id_is_null.or(report_id_from_verified_report))
    end

    def without_active_or_completed_delivery
      where.not(id: Delivery.active_or_completed.select(:document_id))
    end

    def with_report
      where.not(report_id: nil)
    end

    def search(query)
      if query[:title].present?
        result = all
        query[:title].split(' ').each do |word|
          result = result.where(arel_table[:title].matches("%#{word}%"))
        end
      else
        result = none
      end
      result
    end
  end

  delegate :path, :content_type, :fingerprint, to: :file
  delegate :fax_number, to: :recipient

  def deliver
    Deliverer.new(self).deliver
  end

  def filename
    self.file_file_name
  end

  def to_deliver?
    released_for_delivery? && deliveries.active_or_completed.empty?
  end

  def delivered?
    deliveries.completed.present?
  end

  def released_for_delivery?
    report.blank? || report.verified?
  end

  def recipient_fax_number?
    recipient.fax_number?
  end

  def report_pdf
    ReportPdf.new(self)
  end

  def assign_report_attributes
    report_pdf.to_file do |file|
      self.file  = file
      self.title = report.title
      yield
    end
  end
end
