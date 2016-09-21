class PopulateReportSignatures < ActiveRecord::Migration
  class Report::Release < ActiveRecord::Base
    class << self
      def with_unsigned_report
        where.not(report_id: Report::Signature.select(:report_id))
      end
    end
  end

  class Report::Signature < ActiveRecord::Base
  end

  def up
    [ Report::Release, Report::Signature ].map(&:reset_column_information)
    Report::Release.with_unsigned_report.find_each do |release|
      Report::Signature.new(
        report_id:  release.report_id,
        user_id:    release.user_id,
        created_at: release.created_at,
        updated_at: release.created_at).save!(validate: false)
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
