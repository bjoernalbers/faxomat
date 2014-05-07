class RemovePatientAttributesFromFaxes < ActiveRecord::Migration
  def change
    remove_column :faxes, :patient_first_name
    remove_column :faxes, :patient_last_name
    remove_column :faxes, :patient_date_of_birth
  end
end
