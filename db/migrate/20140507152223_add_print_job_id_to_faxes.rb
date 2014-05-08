class AddPrintJobIdToFaxes < ActiveRecord::Migration
  def change
    add_column :faxes, :print_job_id, :integer
  end
end
