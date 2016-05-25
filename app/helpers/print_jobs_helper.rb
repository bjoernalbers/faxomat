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

  def print_job_status_class(print_job)
    case print_job.status.to_sym
    when :active    then 'default'
    when :completed then 'success'
    when :aborted   then 'danger'
    end
  end
end
