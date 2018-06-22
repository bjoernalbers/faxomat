class AddIndexToJobNumberAndPrinterIdOnDeliveries < ActiveRecord::Migration
  def up
    remove_index :deliveries, :job_number
    add_index :deliveries, [:job_number, :printer_id], unique: true
  end

  def down
    remove_index :deliveries, [:job_number, :printer_id]
    add_index :deliveries, :job_number, unique: true
  end
end
