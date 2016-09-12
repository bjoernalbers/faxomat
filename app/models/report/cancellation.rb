class Report::Cancellation < ActiveRecord::Base
  include Report::StatusChange

  validate :report_has_verification, if: :report

  private

  def report_has_verification
    unless report.verifications.present?
      errors[:report] << 'ist nicht vidiert'
    end
  end
end
