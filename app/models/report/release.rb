class Report::Release < ActiveRecord::Base
  belongs_to :report, required: true
  belongs_to :user, required: true

  validates :report, uniqueness: true

  after_commit :update_documents_from_report, on: [:create, :update]

  acts_as_paranoid

  private

  def update_documents_from_report
    # NOTE: Reloading report is required to refresh the (cached) status.
    report.reload.update_documents
  end
end
