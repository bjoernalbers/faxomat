class ChangeCupsJobIdOnFaxes < ActiveRecord::Migration
  def change
    change_column :faxes, :cups_job_id, :integer, null: true
  end
end
