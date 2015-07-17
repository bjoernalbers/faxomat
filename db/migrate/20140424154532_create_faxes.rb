class CreateFaxes < ActiveRecord::Migration
  def change
    create_table :faxes do |t|
      t.integer :recipient_id
      t.string :path
      t.string :patient_first_name
      t.string :patient_last_name
      t.date :patient_date_of_birth

      t.timestamps
    end
  end
end
