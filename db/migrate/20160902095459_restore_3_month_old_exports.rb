class Restore3MonthOldExports < ActiveRecord::Migration
  def up
    Export.only_deleted.where(created_at: 3.months.ago..Time.zone.now).
      find_each do |export|
        export.restore
      end
  end

  def down
    Export.without_deleted.where(created_at: 3.months.ago..3.weeks.ago).
      find_each do |export|
        export.destroy
      end
  end
end
