class Report < ActiveRecord::Base
  enum status: { pending: 0, approved: 1, canceled: 2 }

  belongs_to :user, required: true
  belongs_to :patient, required: true
  belongs_to :recipient, required: true

  validates_presence_of :subject, :content

  def title
    patient.display_name
  end
end
