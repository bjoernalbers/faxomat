class AddIndexOnReportSignaturesForReportAndUser < ActiveRecord::Migration
  def change
    add_index :report_signatures, [:report_id, :user_id], unique: true
  end
end
