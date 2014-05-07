class AddDeliveredAtToFaxes < ActiveRecord::Migration
  def change
    add_column :faxes, :delivered_at, :datetime
  end
end
