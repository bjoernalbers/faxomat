class AddPortToPrinters < ActiveRecord::Migration
  def change
    add_column :printers, :port, :integer, null: false, default: 4559
  end
end
