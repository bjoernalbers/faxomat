class ChangePatientIdOnFaxes < ActiveRecord::Migration
  def change
    change_column :faxes, :patient_id, :integer, null: false
  end
end
