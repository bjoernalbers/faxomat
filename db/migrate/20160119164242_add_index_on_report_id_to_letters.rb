class AddIndexOnReportIdToLetters < ActiveRecord::Migration
  def change
    add_index :letters, :report_id, unique: true
  end
end
