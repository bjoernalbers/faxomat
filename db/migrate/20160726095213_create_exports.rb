class CreateExports < ActiveRecord::Migration
  def change
    create_table :exports do |t|
      t.integer :status, default: 0, null: false
      t.string :filename, null: false
      t.references :document, index: true, foreign_key: true, null: false
      t.references :directory, index: true, foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
