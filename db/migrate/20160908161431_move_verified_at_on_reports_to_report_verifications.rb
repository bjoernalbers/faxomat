class MoveVerifiedAtOnReportsToReportVerifications < ActiveRecord::Migration
  class Report < ActiveRecord::Base
    class << self
      def where_verified_at_must_be_moved
        with_verified_at.without_verification
      end

      def with_verified_at
        where.not(verified_at: nil)
      end

      def without_verification
        where.not(id: Verification.select(:report_id))
      end
    end
  end

  class Report::Verification < ActiveRecord::Base
  end

  def up
    [ Report, Report::Verification ].map(&:reset_column_information)
    Report.where_verified_at_must_be_moved.find_each do |report|
      Report::Verification.create!(
        report_id:  report.id,
        user_id:    report.user_id,
        created_at: report.verified_at,
        updated_at: report.verified_at)
      report.update!(verified_at: nil)
    end
    remove_column :reports, :verified_at
  end

  def down
    [ Report, Report::Verification ].map(&:reset_column_information)
    add_column :reports, :verified_at, :datetime
    Report::Verification.find_each do |verification|
      report = Report.find(verification.report_id)
      report.update!(verified_at: verification.created_at)
      verification.destroy!
    end
  end
end
