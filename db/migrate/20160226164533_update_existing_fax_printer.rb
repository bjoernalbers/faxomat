class UpdateExistingFaxPrinter < ActiveRecord::Migration
  class Printer < ActiveRecord::Base
  end

  def up
    Printer.reset_column_information

    if printer = Printer.find_by(name: 'Fax')
      printer.update(is_fax_printer: true)
    end
  end

  def down
  end
end
