class CreateReportVerifications < ActiveRecord::Migration
  def change
    create_table :report_verifications do |t|
      t.references :report, null: false, foreign_key: true, index: { unique: true }
      t.references :user,   null: false, foreign_key: true, index: true

      t.timestamps null: false
    end
  end
end
