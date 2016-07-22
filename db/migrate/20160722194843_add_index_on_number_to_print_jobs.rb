class AddIndexOnNumberToPrintJobs < ActiveRecord::Migration
  def change
    add_index :print_jobs, :number, unique: true
  end
end
