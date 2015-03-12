class RemoveStateFromFaxes < ActiveRecord::Migration
  def change
    remove_column :faxes, :state
  end
end
