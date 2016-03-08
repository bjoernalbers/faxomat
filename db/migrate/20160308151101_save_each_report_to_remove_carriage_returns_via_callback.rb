class SaveEachReportToRemoveCarriageReturnsViaCallback < ActiveRecord::Migration
  def up
    Report.find_each { |r| r.save }
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
