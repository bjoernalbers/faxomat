class AssignRecipientsToDocuments < ActiveRecord::Migration
  class Document < ActiveRecord::Base; end
  class Recipient < ActiveRecord::Base; end
  class Report < ActiveRecord::Base; end

  def up
    [ Document, Recipient, Report ].
      map(&:reset_column_information)
    Document.where(recipient_id: nil).find_each do |document|
      if report = Report.find_by(document_id: document.id)
        recipient = Recipient.find(report.recipient_id)
      else
        # Find the document's last print job with fax number.
        if print_job = PrintJob.order(:created_at).
          where(document_id: document.id).where.not(fax_number: nil).last
          recipient = Recipient.order('created_at DESC').
            find_or_create_by(fax_number: print_job.fax_number)
        else
          @fallback_recipient ||= Recipient.create!
          puts "Assigning fallback Recipient #{@fallback_recipient.id} to Document #{document.id}!"
          recipient = @fallback_recipient
        end
      end
      document.update_columns(recipient_id: recipient.id)
    end
    change_column :documents, :recipient_id, :integer, null: false
  end

  def down
    Document.reset_column_information
    change_column :documents, :recipient_id, :integer, null: true
    Document.update_all(recipient_id: nil)
  end
end
