class AddReportIdToDocuments < ActiveRecord::Migration
  def change
    add_reference :documents, :report, index: {:unique=>true}, foreign_key: true
  end
end
