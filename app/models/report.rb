class Report < ActiveRecord::Base
  enum status: { pending: 0, approved: 1 }

  belongs_to :user, required: true
  belongs_to :patient, required: true

  validates_presence_of :subject, :content
end
