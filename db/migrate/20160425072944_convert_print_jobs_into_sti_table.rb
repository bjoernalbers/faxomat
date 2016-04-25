class ConvertPrintJobsIntoStiTable < ActiveRecord::Migration
  def up
    add_column :print_jobs, :type, :string
    execute "UPDATE print_jobs SET type = 'PrintJob'"
    rename_table :print_jobs, :deliveries
  end

  def down
    rename_table :deliveries, :print_jobs
    remove_column :print_jobs, :type, :string
  end
end
