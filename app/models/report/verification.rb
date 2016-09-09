class Report::Verification < ActiveRecord::Base
  belongs_to :report, required: true
  belongs_to :user, required: true

  validates :report, uniqueness: true

  after_commit :update_documents_from_report, on: :create

  private

  def update_documents_from_report
    report.update_documents
  end
end
