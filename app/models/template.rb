class EmptyTemplate
  include ActiveModel::Model

  def method_missing(method_name, *args)
    ''
  end
end

class Template < ActiveRecord::Base
  # Returns default template
  def self.default
    first || EmptyTemplate.new
  end

  has_attached_file :logo,
    path: ':rails_root/storage/:rails_env/:class/:id/:attachment/:filename'

  validates_attachment :logo,
    content_type: { content_type: 'image/png' }
end
