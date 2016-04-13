class RenameDocumentOnPrintJobs < ActiveRecord::Migration
  def change
    rename_column :print_jobs, :document_file_name,    :embedded_document_file_name
    rename_column :print_jobs, :document_content_type, :embedded_document_content_type
    rename_column :print_jobs, :document_file_size,    :embedded_document_file_size
    rename_column :print_jobs, :document_updated_at,   :embedded_document_updated_at
    rename_column :print_jobs, :document_fingerprint,  :embedded_document_fingerprint
  end
end
