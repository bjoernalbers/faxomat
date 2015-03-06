class RenameCupsStateToCupsStatusOnPrintJobs < ActiveRecord::Migration
  def change
    rename_column :print_jobs, :cups_state, :cups_status
  end
end
