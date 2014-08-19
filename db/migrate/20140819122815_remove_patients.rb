class RemovePatients < ActiveRecord::Migration
  def up
    drop_table :patients
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
