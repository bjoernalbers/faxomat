class Document::Deliverer
  attr_reader :document, :recipient

  def initialize(document)
    @document  = document
    @recipient = document.recipient
  end

  def deliver
    document.print_jobs.create(printer: printer)
  end

  private

  def printer
    (recipient.fax_number.present? ? FaxPrinter : PaperPrinter).default
  end
end
