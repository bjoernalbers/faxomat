class MoveCanceledAtOnReportsToReportCancellations < ActiveRecord::Migration
  class Report < ActiveRecord::Base
    class << self
      def where_canceled_at_must_be_moved
        with_canceled_at.without_cancellation
      end

      def with_canceled_at
        where.not(canceled_at: nil)
      end

      def without_cancellation
        where.not(id: Cancellation.select(:report_id))
      end
    end
  end

  class Report::Cancellation < ActiveRecord::Base
  end

  def up
    [ Report, Report::Cancellation ].map(&:reset_column_information)
    Report.where_canceled_at_must_be_moved.find_each do |report|
      Report::Cancellation.create!(
        report_id:  report.id,
        user_id:    report.user_id,
        created_at: report.canceled_at,
        updated_at: report.canceled_at)
      report.update!(canceled_at: nil)
    end
    remove_column :reports, :canceled_at
  end

  def down
    [ Report, Report::Cancellation ].map(&:reset_column_information)
    add_column :reports, :canceled_at, :datetime
    Report::Cancellation.find_each do |cancellation|
      report = Report.find(cancellation.report_id)
      report.update!(canceled_at: cancellation.created_at)
      cancellation.destroy!
    end
  end
end
