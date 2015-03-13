class RemoveDeliveryAttemptsFromFaxes < ActiveRecord::Migration
  def change
    remove_column :faxes, :delivery_attempts
  end
end
