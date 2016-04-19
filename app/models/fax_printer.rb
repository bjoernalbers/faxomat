class FaxPrinter < Printer
  def self.default
    first
  end

  def is_fax_printer?
    true
  end
end
