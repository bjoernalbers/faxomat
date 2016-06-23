class RemoveRecipientIdFromReports < ActiveRecord::Migration
  def up
    remove_column :reports, :recipient_id
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
