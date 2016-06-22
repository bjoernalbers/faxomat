class ChangeDateOfBirthOnPatientsFromDatetimeToDate < ActiveRecord::Migration
  class Patient < ActiveRecord::Base
  end

  def up
    Patient.reset_column_information
    add_column :patients, :temp_date_of_birth, :date
    Patient.find_each do |patient|
      patient.update_columns(temp_date_of_birth: patient.date_of_birth.to_date)
    end
    remove_column :patients, :date_of_birth
    rename_column :patients, :temp_date_of_birth, :date_of_birth
    change_column :patients, :date_of_birth, :date, null: false
  end

  def down
    change_column :patients, :date_of_birth, :datetime, null: false
  end
end
