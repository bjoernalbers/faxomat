class CreateDeliveries < ActiveRecord::Migration
  def change
    create_table :deliveries do |t|
      t.integer :cups_id
      t.string :cups_state
      t.references :fax, index: true

      t.timestamps
    end
    add_index :deliveries, :cups_id, unique: true
  end
end
