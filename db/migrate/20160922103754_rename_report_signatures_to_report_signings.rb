class RenameReportSignaturesToReportSignings < ActiveRecord::Migration
  def change
    rename_table :report_signatures, :report_signings
  end
end
