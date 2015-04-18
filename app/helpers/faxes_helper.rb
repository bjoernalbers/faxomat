module FaxesHelper
  def aborted_faxes_count
    count = Fax.aborted.count
    count.zero? ? nil : count
  end

  def fax_report_header
    timestamp = Time.zone.now.iso8601
    linelength = 66
    title = 'Fax-Bericht'
    title + timestamp.rjust(linelength-title.size)
  end
end
