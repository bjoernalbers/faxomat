class AddNameIndexOnPrinters < ActiveRecord::Migration
  def change
    add_index :printers, :name, unique: true
  end
end
