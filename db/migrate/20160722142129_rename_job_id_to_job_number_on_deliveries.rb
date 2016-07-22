class RenameJobIdToJobNumberOnDeliveries < ActiveRecord::Migration
  def change
    rename_column :deliveries, :job_id, :job_number
  end
end
