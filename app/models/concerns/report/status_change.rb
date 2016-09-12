module Report::StatusChange
  extend ActiveSupport::Concern

  included do
    belongs_to :report, required: true
    belongs_to :user, required: true

    validates :report, uniqueness: true

    after_commit :update_documents_from_report, on: :create
  end

  private

  def update_documents_from_report
    # NOTE: Reloading report is required to refresh the (cached) status.
    report.reload.update_documents
  end
end
