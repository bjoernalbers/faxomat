class RenamePatientNumberToNumberOnPatients < ActiveRecord::Migration
  def change
    rename_column :patients, :patient_number, :number
  end
end
