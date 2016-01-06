class ChangeStudyOnReports < ActiveRecord::Migration
  def up
    change_column :reports, :study, :string, null: false
  end

  def down
    change_column :reports, :study, :text, null: true
  end
end
