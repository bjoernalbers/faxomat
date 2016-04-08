class GenerateDocumentForEachReport < ActiveRecord::Migration
  def up
    Report.find_each do |report|
      report.send(:create_report_document) unless report.document
    end
  end

  def down
    # Nothing to do here.
  end
end
