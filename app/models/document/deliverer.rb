class Document::Deliverer
  attr_reader :document, :recipient

  def initialize(document)
    @document  = document
    @recipient = document.recipient
  end

  def deliver
    document.prints.create(printer: printer)
  end

  private

  def printer
    (recipient.fax_number.present? ? FaxPrinter : PaperPrinter).default
  end
end
