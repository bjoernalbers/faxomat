class RemovePathFromFaxes < ActiveRecord::Migration
  def up
    remove_column :faxes, :path
  end

  def down
    add_column :faxes, :path, :string
  end
end
