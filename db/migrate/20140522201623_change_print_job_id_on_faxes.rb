class ChangePrintJobIdOnFaxes < ActiveRecord::Migration
  def change
    add_index :faxes, :print_job_id, unique: true
  end
end
