class AddDocumentIdToPrintJobs < ActiveRecord::Migration
  def change
    add_reference :print_jobs, :document, index: true, foreign_key: true
  end
end
