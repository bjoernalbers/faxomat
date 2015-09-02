class AddPatientIdToReports < ActiveRecord::Migration
  def change
    add_column :reports, :patient_id, :integer
    change_column :reports, :patient_id, :integer, null: false
  end
end
