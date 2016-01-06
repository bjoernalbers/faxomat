class Report < ActiveRecord::Base
  enum status: { pending: 0, approved: 1, canceled: 2 }

  belongs_to :user, required: true
  belongs_to :patient, required: true
  belongs_to :recipient, required: true

  validates_presence_of :anamnesis,
    :evaluation,
    :procedure,
    :study_date

  def subject
    study
  end

  def title
    patient.display_name
  end

  def deliver_as_fax
    ReportFaxer.deliver(self)
  end
end
