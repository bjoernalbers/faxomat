class AddIsFaxPrinterToPrinters < ActiveRecord::Migration
  def change
    add_column :printers, :is_fax_printer, :boolean
  end
end
