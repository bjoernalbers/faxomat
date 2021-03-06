class Document::Deliverer
  attr_reader :document, :recipient

  def initialize(document)
    @document  = document
    @recipient = document.recipient
  end

  def deliver
    print_document
    export_document if document.recipient_is_evk?
  rescue StandardError => e
    Rails.logger.error(e.message)
  end

  def print_document
    document.prints.create(printer: printer)
  end

  def export_document
    document.exports.create(directory: directory) if directory
  end


  private

  def printer
    (if recipient.fax_number.present?
      recipient.send_with_hylafax? ? HylafaxPrinter : FaxPrinter
    else
      PaperPrinter
    end).default
  end

  def directory
    Directory.default
  end
end
