class Document < ActiveRecord::Base
  belongs_to :recipient, required: true
  has_one :report
  has_many :print_jobs

  has_attached_file :file,
    path: ':rails_root/storage/:rails_env/:class/:id/:attachment/:filename'

  validates_presence_of :title
  validates_attachment :file,
    presence: true,
    content_type: { content_type: 'application/pdf' }

  class << self
    def created_today
      where('created_at > ?', Time.zone.now.beginning_of_day)
    end

    def to_deliver
      released_for_delivery.without_active_or_completed_print_job
    end

    def released_for_delivery
      where.not(id: Report.not_verified.select(:document_id))
    end

    def without_active_or_completed_print_job
      where.not(id: PrintJob.active_or_completed.select(:document_id))
    end

    def with_report
      joins(:report)
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
end
