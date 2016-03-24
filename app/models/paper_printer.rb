class PaperPrinter < Printer
  def self.default_driver_class
    superclass.default_driver_class
  end
end
