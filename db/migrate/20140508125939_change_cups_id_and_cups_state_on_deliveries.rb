class ChangeCupsIdAndCupsStateOnDeliveries < ActiveRecord::Migration
  def change
    rename_column :deliveries, :cups_id, :print_job_id
    rename_column :deliveries, :cups_state, :print_job_state
  end
end
