class CreateReportSignatures < ActiveRecord::Migration
  def change
    create_table :report_signatures do |t|
      t.references :report, foreign_key: true, null: false
      t.references :user,   foreign_key: true, null: false

      t.timestamps null: false
    end
  end
end
