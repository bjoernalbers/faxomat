class CreateReports < ActiveRecord::Migration
  def change
    create_table :reports do |t|
      t.string :subject, null: false
      t.text :content, null: false
      t.references :user, index: true, null: false, foreign_key: true

      t.timestamps null: false
    end
  end
end
