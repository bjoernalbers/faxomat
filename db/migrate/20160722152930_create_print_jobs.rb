class CreatePrintJobs < ActiveRecord::Migration
  def change
    create_table :print_jobs do |t|
      t.integer :number, null: false
      t.string :fax_number
      t.references :printer, index: true, null: false, foreign_key: true

      t.timestamps null: false
    end
  end
end
