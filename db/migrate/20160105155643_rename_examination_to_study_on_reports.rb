class RenameExaminationToStudyOnReports < ActiveRecord::Migration
  def change
    rename_column :reports, :examination, :study
  end
end
