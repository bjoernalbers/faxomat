class ReportPresenter
  attr_reader :report

  delegate :patient, to: :report
  delegate :recipient, to: :report
  delegate :user, to: :report
  delegate :subject, to: :report
  delegate :content, to: :report

  def initialize(report, template)
    @report = report
    @template = template
  end

  def patient_name
    patient.display_name
  end

  def recipient_name
    recipient.full_name
  end

  def recipient_address
    recipient.full_address
  end

  def salutation
    'Sehr geehrte Kollegen,'
  end

  def report_date
    report.created_at.strftime('%-d.%-m.%Y') if report.created_at.present?
  end

  def valediction
    'Mit freundlichen Grüßen'
  end

  def physician_name
    user.full_name
  end

  #def physician_signature
  #end

  def watermark
    if report.pending?
      'ENTWURF'
    elsif report.canceled?
      'STORNIERT'
    end
  end
end
