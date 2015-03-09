class AddStatusToFaxes < ActiveRecord::Migration
  def change
    add_column :faxes, :status, :integer, null: false, default: 0
  end
end
