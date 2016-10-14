class AddDeletedAtToPrinters < ActiveRecord::Migration
  def change
    add_column :printers, :deleted_at, :datetime
    add_index  :printers, :deleted_at
  end
end
