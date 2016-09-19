class RenameReportVerificationsToReportReleases < ActiveRecord::Migration
  def change
    rename_table :report_verifications, :report_releases
  end
end
