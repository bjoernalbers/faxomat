class ChangeStatusOnPrintJobs < ActiveRecord::Migration
  def up
    change_column :print_jobs, :status, :integer, null: false, default: 0
  end

  def down
    change_column :print_jobs, :status, :integer, null: true, default: nil
  end
end
