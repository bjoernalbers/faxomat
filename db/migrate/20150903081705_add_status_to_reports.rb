class AddStatusToReports < ActiveRecord::Migration
  def change
    add_column :reports, :status, :integer, null: false, default: 0
  end
end
