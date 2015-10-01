class RemoveContentFromReports < ActiveRecord::Migration
  def change
    remove_column :reports, :content
  end
end
