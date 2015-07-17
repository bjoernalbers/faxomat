class ChangeTitleOnFaxes < ActiveRecord::Migration
  def change
    change_column :faxes, :title, :string, null: false
  end
end
