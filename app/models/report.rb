class Report < ActiveRecord::Base
  belongs_to :user, required: true
  belongs_to :patient, required: true

  validates_presence_of :subject, :content
end
