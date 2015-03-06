class AddStatusToPrintJobs < ActiveRecord::Migration
  def change
    add_column :print_jobs, :status, :integer, null: false, default: 0
  end
end
