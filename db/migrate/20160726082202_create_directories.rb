class CreateDirectories < ActiveRecord::Migration
  def change
    create_table :directories do |t|
      t.string :description, null: false
      t.string :path, null: false

      t.timestamps null: false
    end
  end
end
