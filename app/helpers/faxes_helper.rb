module FaxesHelper
  def aborted_faxes_count
    count = Fax.aborted.count
    count.zero? ? nil : count
  end
end
