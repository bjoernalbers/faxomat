class CreateLetters < ActiveRecord::Migration
  def change
    create_table :letters do |t|
      t.integer :report_id, null: false
      t.integer :user_id, null: false

      t.timestamps null: false
    end
  end
end
