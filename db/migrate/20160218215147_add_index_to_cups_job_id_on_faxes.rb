class AddIndexToCupsJobIdOnFaxes < ActiveRecord::Migration
  def change
    add_index :faxes, :cups_job_id, unique: true
  end
end
