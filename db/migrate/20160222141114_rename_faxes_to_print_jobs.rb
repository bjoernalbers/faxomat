class RenameFaxesToPrintJobs < ActiveRecord::Migration
  def change
    rename_table :faxes, :print_jobs
  end
end
