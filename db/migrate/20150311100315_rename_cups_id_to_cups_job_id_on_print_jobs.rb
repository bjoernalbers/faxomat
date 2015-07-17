class RenameCupsIdToCupsJobIdOnPrintJobs < ActiveRecord::Migration
  def change
    rename_column :print_jobs, :cups_id, :cups_job_id
  end
end
