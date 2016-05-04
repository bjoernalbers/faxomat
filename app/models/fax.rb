class Fax
  include ActiveModel::Model

  attr_accessor :title, :phone, :document, :printer
  validates_presence_of :title, :phone, :document, :printer

  def save!
    raise 'Ouch!' unless save
  end

  def save
    if valid?
      doc = Document.new(title: title, recipient: recipient)
      doc.file = document
      doc.save
      printer.print_jobs.new(document: doc, fax_number: phone).save
    else
      false
    end
  end

  private

  def recipient
    @recipient ||= Recipient.order('created_at DESC').
      find_or_create_by(fax_number: phone)
  end
end
