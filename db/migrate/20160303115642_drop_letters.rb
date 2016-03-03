class DropLetters < ActiveRecord::Migration
  def up
    drop_table :letters
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
