class RenameCupsJobIdToJobIdOnPrintJobs < ActiveRecord::Migration
  def change
    rename_column :print_jobs, :cups_job_id, :job_id
  end
end
