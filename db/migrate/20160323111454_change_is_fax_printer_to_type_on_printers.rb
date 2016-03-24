class ChangeIsFaxPrinterToTypeOnPrinters < ActiveRecord::Migration
  class Printer < ActiveRecord::Base
  end

  def up
    Printer.reset_column_information

    add_column :printers, :type, :string
    Printer.update_all(type: 'PaperPrinter')
    Printer.where(is_fax_printer: true).update_all(type: 'FaxPrinter')
    remove_column :printers, :is_fax_printer
  end

  def down
    Printer.reset_column_information

    add_column :printers, :is_fax_printer, :boolean
    Printer.where(type: 'FaxPrinter').update_all(is_fax_printer: true)
    remove_column :printers, :type
  end
end
