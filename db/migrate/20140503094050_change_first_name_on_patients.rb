class ChangeFirstNameOnPatients < ActiveRecord::Migration
  def change
    change_column :patients, :first_name, :string, null: false
  end
end
