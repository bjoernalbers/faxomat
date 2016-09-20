class RenameDeletedAtOnReportReleasesToCanceledAt < ActiveRecord::Migration
  def change
    rename_column :report_releases, :deleted_at, :canceled_at
  end
end
