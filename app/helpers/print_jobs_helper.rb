module PrintJobsHelper
  def aborted_print_jobs_count
    count = PrintJob.aborted.count
    count.zero? ? nil : count
  end

  def print_job_report_header
    timestamp = Time.zone.now.iso8601
    linelength = 66
    title = 'Fax-Bericht'
    title + timestamp.rjust(linelength-title.size)
  end
end
