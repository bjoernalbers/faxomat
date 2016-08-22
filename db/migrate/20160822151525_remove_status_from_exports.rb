class RemoveStatusFromExports < ActiveRecord::Migration
  class Export < ActiveRecord::Base
  end

  def up
    remove_column :exports, :status, :integer
  end

  def down
    Export.reset_column_information
    add_column :exports, :status, :integer, default: 0, null: false
    Export.update_all(status: 1)
  end
end
