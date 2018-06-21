class HylafaxPrinter < Printer
  validates_presence_of :host, :port, :user, :password

  def self.default
    first
  end

  def is_fax_printer?
    true
  end
end
