class ChangePathOnFaxes < ActiveRecord::Migration
  def change
    change_column :faxes, :path, :string, null: false
  end
end
