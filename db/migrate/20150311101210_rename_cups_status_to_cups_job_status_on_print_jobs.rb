class RenameCupsStatusToCupsJobStatusOnPrintJobs < ActiveRecord::Migration
  def change
    rename_column :print_jobs, :cups_status, :cups_job_status
  end
end
