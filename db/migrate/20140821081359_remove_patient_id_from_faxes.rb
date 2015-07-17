class RemovePatientIdFromFaxes < ActiveRecord::Migration
  def up
    remove_column :faxes, :patient_id
  end

  def down
    add_column :faxes, :patient_id, :integer
  end
end
