class ChangeFaxIdOnDeliveries < ActiveRecord::Migration
  def change
    change_column :deliveries, :fax_id, :integer, null: false
  end
end
