class CreatePrintJobs < ActiveRecord::Migration
  def change
    create_table :print_jobs do |t|
      t.integer :cups_id
      t.string :cups_state
      t.references :fax, index: true

      t.timestamps
    end
    add_index :print_jobs, :cups_id, unique: true
  end
end
