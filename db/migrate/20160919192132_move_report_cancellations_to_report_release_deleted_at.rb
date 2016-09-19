class MoveReportCancellationsToReportReleaseDeletedAt < ActiveRecord::Migration
  class Report < ActiveRecord::Base; end
  class Report::Release < ActiveRecord::Base; end
  class Report::Cancellation < ActiveRecord::Base; end

  def reset_all_column_information
    [ Report, Report::Release, Report::Cancellation ].
      map(&:reset_column_information)
  end

  def up
    reset_all_column_information
    Report::Cancellation.find_each do |cancellation|
      release = Report::Release.find_by!(report_id: cancellation.report_id)
      release.update_columns(deleted_at: cancellation.created_at)
      cancellation.delete
    end
  end

  def down
    reset_all_column_information
    Report::Release.where.not(deleted_at: nil).find_each do |release|
      Report::Cancellation.create!(
        report_id:  release.report_id,
        user_id:    release.user_id,
        created_at: release.deleted_at,
        updated_at: release.deleted_at
      )
      release.update_columns(deleted_at: nil)
    end
  end
end
