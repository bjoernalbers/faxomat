class RemovePrintJobIdFromFaxes < ActiveRecord::Migration
  def change
    remove_column :faxes, :print_job_id
  end
end
