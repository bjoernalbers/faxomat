class ConvertCupsJobStatusOnPrintJobs < ActiveRecord::Migration
  def up
    PrintJob.where(cups_job_status: 'undeliverable').find_each do |print_job|
      print_job.update(cups_job_status: 'aborted') 
    end
  end

  def down
    fail ActiveRecord::IrreversibleMigration, 'unable to convert data back'
  end
end
