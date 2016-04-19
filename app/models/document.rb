class Document < ActiveRecord::Base
  belongs_to :report
  has_many :print_jobs

  has_attached_file :file,
    path: ':rails_root/storage/:rails_env/:class/:id/:attachment/:filename'

  validates_presence_of :title
  validates_uniqueness_of :report_id, allow_nil: true
  validates_attachment :file,
    presence: true,
    content_type: { content_type: 'application/pdf' }

  class << self
    def to_deliver
      where.not(id: PrintJob.active_or_completed.select(:document_id))
    end
  end

  delegate :path, :content_type, :fingerprint, to: :file

  def filename
    self.file_file_name
  end

  def to_deliver?
    print_jobs.active_or_completed.empty?
  end
end
