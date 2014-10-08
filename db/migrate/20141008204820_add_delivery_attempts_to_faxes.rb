class AddDeliveryAttemptsToFaxes < ActiveRecord::Migration
  def change
    add_column :faxes, :delivery_attempts, :integer
  end
end
