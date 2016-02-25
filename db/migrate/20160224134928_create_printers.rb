class CreatePrinters < ActiveRecord::Migration
  class Printer < ActiveRecord::Base
  end

  class PrintJob < ActiveRecord::Base
  end

  def up
    Printer.reset_column_information
    PrintJob.reset_column_information

    create_table :printers do |t|
      t.string :name
      t.string :label
      t.integer :dialout_prefix

      t.timestamps null: false
    end
    printer = Printer.create! name: 'Fax', label: 'Faxgerät'
    add_column :print_jobs, :printer_id, :integer
    PrintJob.update_all(printer_id: printer.id)
    change_column :print_jobs, :printer_id, :integer, null: false
  end

  def down
    Printer.reset_column_information
    PrintJob.reset_column_information

    remove_column :print_jobs, :printer_id
    drop_table :printers
  end
end
