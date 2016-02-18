class MergePrintJobsIntoFaxes < ActiveRecord::Migration
  class Fax < ActiveRecord::Base
  end

  class PrintJob < ActiveRecord::Base
  end

  def up
    Fax.reset_column_information
    PrintJob.reset_column_information

    add_column :faxes, :cups_job_id, :integer, unique: true
    Fax.find_each do |fax|
      last_print_job = PrintJob.where(fax_id: fax.id).order(:created_at).last
      fax.update_columns(
        status:      last_print_job.status,
        cups_job_id: last_print_job.cups_job_id) unless last_print_job.nil?
    end
    change_column :faxes, :cups_job_id, :integer, unique: true, null: false
    
    drop_table :print_jobs, force: :cascade
  end

  def down
    Fax.reset_column_information
    PrintJob.reset_column_information

    create_table "print_jobs", force: :cascade do |t|
      t.integer  "cups_job_id",                             null: false
      t.string   "cups_job_status", limit: 255
      t.integer  "fax_id",                                  null: false
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "status",                      default: 0, null: false
    end

    add_index "print_jobs", ["cups_job_id"], name: "index_print_jobs_on_cups_job_id", unique: true
    add_index "print_jobs", ["fax_id"], name: "index_print_jobs_on_fax_id"

    Fax.find_each do |fax|
      cups_job_status =
        case fax.status
        when 0 then 'active'
        when 1 then 'completed'
        when 2 then 'aborted'
        end
      PrintJob.create!(
        cups_job_id:     fax.cups_job_id,
        cups_job_status: cups_job_status,
        fax_id:          fax.id,
        created_at:      fax.created_at,
        updated_at:      fax.updated_at,
        status:          fax.status)
    end

    remove_column :faxes, :cups_job_id
  end
end
