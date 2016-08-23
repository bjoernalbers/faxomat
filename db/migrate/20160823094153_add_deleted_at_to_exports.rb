class AddDeletedAtToExports < ActiveRecord::Migration
  def change
    add_column :exports, :deleted_at, :datetime
    add_index :exports, :deleted_at
  end
end
