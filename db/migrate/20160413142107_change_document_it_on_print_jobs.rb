class ChangeDocumentItOnPrintJobs < ActiveRecord::Migration
  def change
    change_column :print_jobs, :document_id, :integer, null: false
  end
end
