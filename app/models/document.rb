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

  scope :undelivered, -> { where.not(id: PrintJob.completed.select(:document_id)) }

  delegate :path, :content_type, :fingerprint, to: :file

  def filename
    self.file_file_name
  end

  def to_deliver?
    print_jobs.completed.empty? && print_jobs.active.empty?
  end
end
