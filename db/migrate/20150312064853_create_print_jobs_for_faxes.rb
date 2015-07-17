class CreatePrintJobsForFaxes < ActiveRecord::Migration
  # Convert Fax#print_job_id to new print job for each fax.
  def up
    Fax.find_each do |fax|
      print_job = fax.print_jobs.new(
        cups_job_id:     fax.print_job_id,
        cups_job_status: fax.state,
        created_at:      fax.created_at,
        updated_at:      fax.updated_at
      )
      if print_job.save
        fax.update(print_job_id: nil)
      end
    end
  end

  # Revert print jobs to Fax#print_job_id.
  def down
    Fax.where(print_job_id: nil).find_each do |fax|
      if print_job = fax.print_jobs.last
        if fax.update(print_job_id: print_job.cups_job_id)
          print_job.destroy
        end
      end
    end
  end
end
