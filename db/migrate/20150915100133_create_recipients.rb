class CreateRecipients < ActiveRecord::Migration
  def change
    create_table :recipients do |t|
      t.string :first_name
      t.string :last_name, null: false
      t.string :title
      t.string :suffix
      t.integer :sex
      t.string :address
      t.string :zip
      t.string :city

      t.timestamps null: false
    end
  end
end
