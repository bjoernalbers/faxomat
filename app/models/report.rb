class Report < ActiveRecord::Base
  belongs_to :user, required: true

  validates_presence_of :subject, :content
end
