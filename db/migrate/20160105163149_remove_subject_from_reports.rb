class RemoveSubjectFromReports < ActiveRecord::Migration
  def change
    remove_column :reports, :subject, :string
  end
end
