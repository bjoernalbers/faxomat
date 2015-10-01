class AddClinicToReports < ActiveRecord::Migration
  def change
    add_column :reports, :clinic, :text
  end
end
