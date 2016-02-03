module ReportsHelper
  def report_status(report)
    case report.status
    when :pending
      "Noch nicht vidiert"
    when :verified
      "Vidiert: #{l(report.verified_at.to_date)}"
    when :canceled
      "Storniert: #{l(report.canceled_at.to_date)}"
    else
      "Unbekannter Status"
    end
  end
end
