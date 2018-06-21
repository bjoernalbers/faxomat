class AddPasswordToPrinters < ActiveRecord::Migration
  def change
    add_column :printers, :password, :string, null: false, default: 'anonymous'
  end
end
