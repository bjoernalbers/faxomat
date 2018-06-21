class AddUserToPrinters < ActiveRecord::Migration
  def change
    add_column :printers, :user, :string, null: false, default: 'anonymous'
  end
end
