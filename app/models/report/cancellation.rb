class Report::Cancellation < ActiveRecord::Base
  include Report::StatusChange

  validate :report_has_release, if: :report

  private

  def report_has_release
    unless report.releases.present?
      errors[:report] << 'ist nicht vidiert'
    end
  end
end
