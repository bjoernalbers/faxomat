class ChangeCupsIdOnPrintJobs < ActiveRecord::Migration
  def change
    change_column :print_jobs, :cups_id, :integer, null: false
  end
end
