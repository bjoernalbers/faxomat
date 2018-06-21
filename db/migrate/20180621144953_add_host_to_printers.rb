class AddHostToPrinters < ActiveRecord::Migration
  def change
    add_column :printers, :host, :string, null: false, default: '127.0.0.1'
  end
end
