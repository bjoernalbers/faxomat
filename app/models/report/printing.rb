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
      self.print_job = report.print_jobs.create(
        printer:    printer,
        title:      report.title,
        fax_number: report.recipient_fax_number,
        document:   report_pdf_file)
      report_pdf_file.close! if report_pdf_file # Close and unlink temp. file.
      true
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

  # TODO: Test this!
  def report_pdf_file
    tmpdir  = Rails.root.join('tmp')
    tmpfile = %w(faxomat .pdf) # Prefix and suffix for temp filename.

    # NOTE: This would return a File instead of of Tempfile (due to re-opening it).
    #Tempfile.open tmpfile, tmpdir, binmode: true do |file|
      #file.write rendered_report_pdf
      #file
    #end.open

    file = Tempfile.open tmpfile, tmpdir, binmode: true
    file.write rendered_report_pdf
    file.flush
    file.rewind
    file
  end

  # TODO: Test this!
  def rendered_report_pdf
    ReportPdf.new(report).render
  end
end
