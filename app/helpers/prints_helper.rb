module PrintsHelper
  def aborted_prints_count
    count = Print.aborted.count
    count.zero? ? nil : count
  end

  def print_report_header
    timestamp = Time.zone.now.iso8601
    linelength = 66
    title = 'Fax-Bericht'
    title + timestamp.rjust(linelength-title.size)
  end

  def print_status_class(print)
    case print.status.to_sym
    when :active    then 'default'
    when :completed then 'success'
    when :aborted   then 'danger'
    end
  end
end
