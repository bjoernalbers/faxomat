class ChangeStudyDateOnReportsToDatetime < ActiveRecord::Migration
  def up
    change_column :reports, :study_date, :datetime, null: false
  end

  def down
    change_column :reports, :study_date, :date, null: false
  end
end
