class CopyFaxNumbersToPrintJobs < ActiveRecord::Migration
  class FaxNumber < ActiveRecord::Base
  end

  class PrintJob < ActiveRecord::Base
  end

  def up
    FaxNumber.reset_column_information
    PrintJob.reset_column_information

    add_column :print_jobs, :fax_number, :string
    PrintJob.find_each do |print_job|
      if fax_number = FaxNumber.find_by(id: print_job.fax_number_id)
        print_job.update_columns(fax_number: fax_number.phone)
      end
    end
    remove_column :print_jobs, :fax_number_id
    drop_table :fax_numbers
  end

  def down
    FaxNumber.reset_column_information
    PrintJob.reset_column_information

    create_table 'fax_numbers', force: :cascade do |t|
      t.string   'phone', limit: 255, null: false
      t.datetime 'created_at'
      t.datetime 'updated_at'
    end
    add_index :fax_numbers, :phone, unique: true
    add_column :print_jobs, :fax_number_id, :integer
    PrintJob.find_each do |print_job|
      fax_number = FaxNumber.find_or_create_by(phone: print_job.fax_number)
      print_job.update_columns(fax_number_id: fax_number.id)
    end
    change_column :print_jobs, :fax_number_id, :integer, null: false
    remove_column :print_jobs, :fax_number
  end
end
