class AddCanReleaseReportsToUsers < ActiveRecord::Migration
  class User < ActiveRecord::Base; end

  def up
    User.reset_column_information
    add_column :users, :can_release_reports, :boolean, null: false,
      default: false
    User.update_all(can_release_reports: true)
  end

  def down
    remove_column :users, :can_release_reports
  end
end
