class RemoveUniqueConstraintFromDocumentsReportIdIndex < ActiveRecord::Migration
  def up
    remove_index :documents, :report_id
    add_index :documents, :report_id, unique: false
  end

  def down
    remove_index :documents, :report_id
    add_index :documents, :report_id, unique: true
  end
end
