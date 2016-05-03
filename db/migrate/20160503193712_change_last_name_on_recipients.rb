class ChangeLastNameOnRecipients < ActiveRecord::Migration
  def up
    change_column :recipients, :last_name, :string, null: true
  end

  def down
    change_column :recipients, :last_name, :string, null: false
  end
end
