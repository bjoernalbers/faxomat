class RemoveIndexOnPatientNumberFromPatients < ActiveRecord::Migration
  def up
    remove_index :patients, :patient_number
  end

  def down
    add_index :patients, :patient_number, unique: true
  end
end
