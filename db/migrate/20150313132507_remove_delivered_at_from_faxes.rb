class RemoveDeliveredAtFromFaxes < ActiveRecord::Migration
  def change
    remove_column :faxes, :delivered_at
  end
end
