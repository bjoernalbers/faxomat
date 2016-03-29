class Document < ActiveRecord::Base
  has_attached_file :file,
    path: ':rails_root/storage/:rails_env/:class/:id/:attachment/:filename'

  validates :title,
    presence: true

  validates_attachment :file,
    presence: true,
    content_type: { content_type: 'application/pdf' }
end
