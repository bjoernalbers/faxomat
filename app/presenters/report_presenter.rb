class ReportPresenter
  attr_reader :report

  delegate :patient, to: :report
  delegate :recipient, to: :report
  delegate :user, to: :report
  delegate :subject, to: :report
  delegate :study, to: :report
  delegate :anamnesis, to: :report
  delegate :diagnosis, to: :report
  delegate :findings, to: :report
  delegate :evaluation, to: :report
  delegate :procedure, to: :report
  delegate :clinic, to: :report

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
    recipient.salutation || 'Sehr geehrte Kollegen,'
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

  def watermark
    case report.status
    when :pending  then 'ENTWURF'
    when :canceled then 'STORNIERT'
    end
  end

  def include_signature?
    report.verified?
  end

  def signature_path
    user.signature_path
  end
end
