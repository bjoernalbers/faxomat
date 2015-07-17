class ChangeLastNameOnPatients < ActiveRecord::Migration
  def change
    change_column :patients, :last_name, :string, null: false
  end
end
