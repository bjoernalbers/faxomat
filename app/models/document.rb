class Document < ActiveRecord::Base
  belongs_to :recipient, required: true
  belongs_to :report
  has_many :print_jobs

  has_attached_file :file,
    path: ':rails_root/storage/:rails_env/:class/:id/:attachment/:filename'

  validates_presence_of :title
  validates_attachment :file,
    presence: true,
    content_type: { content_type: 'application/pdf' }

  class << self
    def delivered_today
      includes(:print_jobs).
        where('deliveries.created_at > ?', Time.zone.now.beginning_of_day).
        order('deliveries.created_at DESC').distinct
    end

    def to_deliver
      released_for_delivery.without_active_or_completed_print_job
    end

    def released_for_delivery
      where.not(report_id: Report.not_verified.select(:id))
    end

    def without_active_or_completed_print_job
      where.not(id: PrintJob.active_or_completed.select(:document_id))
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

  def filename
    self.file_file_name
  end

  # TODO: Remove(?)!
  def to_deliver?
    print_jobs.active_or_completed.empty?
  end

  def delivered?
    print_jobs.completed.present?
  end

  def released_for_delivery?
    report.blank? || report.verified?
  end

  def recipient_fax_number?
    recipient.fax_number?
  end
end
