class ChangeDateOfBirthOnPatients < ActiveRecord::Migration
  def change
    change_column :patients, :date_of_birth, :date, null: false
  end
end
