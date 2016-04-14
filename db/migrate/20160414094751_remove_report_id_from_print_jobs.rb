class RemoveReportIdFromPrintJobs < ActiveRecord::Migration
  def change
    remove_column :print_jobs, :report_id, :integer
  end
end
