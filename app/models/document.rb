class Document < ActiveRecord::Base
  belongs_to :report

  has_attached_file :file,
    path: ':rails_root/storage/:rails_env/:class/:id/:attachment/:filename'

  validates_presence_of :title
  validates_uniqueness_of :report_id, allow_nil: true
  validates_attachment :file,
    presence: true,
    content_type: { content_type: 'application/pdf' }

  delegate :path, :content_type, :fingerprint, to: :file

  def filename
    self.file_file_name
  end
end
