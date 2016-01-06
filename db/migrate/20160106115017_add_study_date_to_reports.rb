class AddStudyDateToReports < ActiveRecord::Migration
  def up
    add_column :reports, :study_date, :date
    Report.find_each do |report|
      if report.created_at.present?
        date = report.created_at.to_date
      else
        date = Time.zone.now.to_date
      end
      report.update!(study_date: date)
    end
    change_column :reports, :study_date, :date, null: false
  end

  def down
    remove_column :reports, :study_date
  end
end
