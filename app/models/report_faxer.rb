class ReportFaxer
  attr_reader :report

  def self.deliver(report)
    new(report).deliver
  end

  def initialize(report)
    @report = report
  end

  def deliver
    if report_verified?
      report.print_jobs.create(
        title:      report_title,
        fax_number: recipient_fax_number,
        document:   report_pdf_file)
    else
      fail 'Report is not verified!'
    end
  ensure
    report_pdf_file.close! if report_pdf_file # Close and unlink temp. file.
  end

  def report_title
    report.title
  end

  def recipient_fax_number
    report.recipient.fax_number
  end

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

  private

  # TODO: Test this!
  def rendered_report_pdf
    ReportPdf.new(ReportPresenter.new(report, ActionView::Base.new)).render
  end

  def report_verified?
    report.verified?
  end
end
