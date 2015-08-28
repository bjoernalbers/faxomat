class CreatePatients < ActiveRecord::Migration
  def change
    create_table :patients do |t|
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.datetime :date_of_birth, null: false
      t.string :title
      t.string :suffix
      t.integer :sex
      t.string :patient_number, null: false

      t.timestamps null: false
    end
    add_index :patients, :patient_number, unique: true
  end
end
