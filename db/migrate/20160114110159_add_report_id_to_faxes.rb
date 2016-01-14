class AddReportIdToFaxes < ActiveRecord::Migration
  def change
    add_column :faxes, :report_id, :integer
  end
end
