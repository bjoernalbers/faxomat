class FaxPrinter < Printer
  def self.default
    first
  end

  def self.default_driver_class
    superclass.default_driver_class
  end

  def is_fax_printer?
    true
  end
end
