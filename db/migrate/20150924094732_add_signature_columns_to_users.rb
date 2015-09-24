class AddSignatureColumnsToUsers < ActiveRecord::Migration
  def up
    add_attachment :users, :signature
  end

  def down
    remove_attachment :users, :signature
  end
end
