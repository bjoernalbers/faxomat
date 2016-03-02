class Template < ActiveRecord::Base
  # Returns default template
  def self.default
    first
  end

  has_attached_file :logo,
    path: ':rails_root/storage/:rails_env/:class/:id/:attachment/:filename'

  validates_attachment :logo,
    content_type: { content_type: 'image/png' }
end
