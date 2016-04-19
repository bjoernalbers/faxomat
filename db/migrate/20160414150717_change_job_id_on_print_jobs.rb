class ChangeJobIdOnPrintJobs < ActiveRecord::Migration
  class PrintJob < ActiveRecord::Base
  end

  def up
    PrintJob.reset_column_information
    PrintJob.where(job_id: nil).delete_all
    change_column :print_jobs, :job_id, :integer, null: false
  end

  def down
    change_column :print_jobs, :job_id, :integer, null: true
  end
end
