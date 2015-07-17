class ChangePhoneOnRecipients < ActiveRecord::Migration
  def change
    change_column :recipients, :phone, :string, null: false
  end
end
