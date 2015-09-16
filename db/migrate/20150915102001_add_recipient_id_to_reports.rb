class AddRecipientIdToReports < ActiveRecord::Migration
  def change
    add_column :reports, :recipient_id, :integer
    change_column :reports, :recipient_id, :integer, null: false
  end
end
