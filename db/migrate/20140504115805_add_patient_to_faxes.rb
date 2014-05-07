class AddPatientToFaxes < ActiveRecord::Migration
  def change
    add_column :faxes, :patient_id, :integer
  end
end
