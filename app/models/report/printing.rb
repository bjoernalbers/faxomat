# Creates print jobs from reports.
class Report::Printing
  include ActiveModel::Model

  attr_accessor :report, :printer, :print_job

  validates :report, :printer, presence: true
  validate :report_must_be_verified

  def report_id=(id)
    self.report = Report.find_by(id: id)
  end

  def report_id
    self.report.id if self.report
  end

  def printer_id=(id)
    self.printer = Printer.find_by(id: id)
  end

  def printer_id
    self.printer.id if self.printer
  end

  def save
    if valid?
      self.print_job = report.print_jobs.new(
        printer:    printer,
        fax_number: report.recipient_fax_number,
        document:   report.document)
      self.print_job.save
    else
      false
    end
  end

  def save!
    raise "Ouch!" unless save
  end

  private

  def report_must_be_verified
    if report.present? && !report.verified?
      errors.add(:report, 'ist noch nicht vidiert')
    end
  end
end
