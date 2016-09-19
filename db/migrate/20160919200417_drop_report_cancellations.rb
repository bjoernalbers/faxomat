class DropReportCancellations < ActiveRecord::Migration
  def up
    drop_table :report_cancellations
  end

  def down
    create_table :report_cancellations do |t|
      t.references :report, null: false, foreign_key: true, index: { unique: true }
      t.references :user,   null: false, foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
