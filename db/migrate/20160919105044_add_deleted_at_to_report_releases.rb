class AddDeletedAtToReportReleases < ActiveRecord::Migration
  def change
    add_column :report_releases, :deleted_at, :datetime
    add_index  :report_releases, :deleted_at
  end
end
