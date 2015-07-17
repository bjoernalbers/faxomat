class ChangeStatusOnFaxes < ActiveRecord::Migration
  def change
    change_column :faxes, :status, :integer, default: nil, null: true
  end
end
