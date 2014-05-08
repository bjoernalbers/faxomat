class ChangeCupsIdOnDeliveries < ActiveRecord::Migration
  def change
    change_column :deliveries, :cups_id, :integer, null: false
  end
end
