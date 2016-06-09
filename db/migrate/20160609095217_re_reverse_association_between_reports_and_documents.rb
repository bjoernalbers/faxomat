class ReReverseAssociationBetweenReportsAndDocuments < ActiveRecord::Migration
  class Report < ActiveRecord::Base
  end

  class Document < ActiveRecord::Base
  end

  def up
    Report.reset_column_information
    Document.reset_column_information
    add_reference :documents, :report, index: {:unique=>true}, foreign_key: true
    Report.find_each do |report|
      if document = Document.find_by(id: report.document_id)
        document.update_column(:report_id, report.id)
      else
        raise "No document found for Report #{report.id}."
      end
    end
    remove_reference :reports, :document, index: { unique: true }, foreign_key: true
  end

  def down
    Report.reset_column_information
    Document.reset_column_information
    add_reference :reports, :document, index: { unique: true }, foreign_key: true
    Report.find_each do |report|
      if document = Document.find_by(report_id: report.id)
        report.update_column(:document_id, document.id)
      else
        raise "No document found for Report #{report.id}."
      end
    end
    change_column :reports, :document_id, :integer, null: false
    remove_reference :documents, :report, index: {:unique=>true}, foreign_key: true
  end
end
