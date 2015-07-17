class AddIndexToRecipients < ActiveRecord::Migration
  def change
    add_index :recipients, :phone, unique: true
  end
end
