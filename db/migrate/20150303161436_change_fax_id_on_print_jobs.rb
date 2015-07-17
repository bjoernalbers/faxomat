class ChangeFaxIdOnPrintJobs < ActiveRecord::Migration
  def change
    change_column :print_jobs, :fax_id, :integer, null: false
  end
end
