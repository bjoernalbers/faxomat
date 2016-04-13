class MigrateEmbeddedDocumentsToDocumentsOnPrintJobs < ActiveRecord::Migration
  class PrintJob < ActiveRecord::Base
    has_attached_file :embedded_document,
      path: ':rails_root/storage/:rails_env/print_jobs/:id/documents/:filename'
  end

  class Document < ActiveRecord::Base
    has_attached_file :file,
      path: ':rails_root/storage/:rails_env/documents/:id/:attachment/:filename'
  end

  def up
    PrintJob.reset_column_information
    Document.reset_column_information
    add_index :print_jobs, :embedded_document_fingerprint
    PrintJob.where(document_id: nil).find_each do |print_job|
      # Assign report document to print job if it exists.
      if print_job.report_id && document = Document.find_by(
        report_id: print_job.report_id)
        print_job.update_column(:document_id, document.id)
      # Or assign existing document by title and fingerprint.
      elsif print_job.embedded_document_fingerprint && document = Document.find_by(
        title:            print_job.title,
        file_fingerprint: print_job.embedded_document_fingerprint)
        print_job.update_column(:document_id, document.id)
      # Else assign new document and move file over.
      else
        document = Document.create!(
          title:             print_job.title,
          file_file_name:    print_job.embedded_document_file_name,
          file_content_type: print_job.embedded_document_content_type,
          file_file_size:    print_job.embedded_document_file_size,
          file_updated_at:   print_job.embedded_document_updated_at,
          file_fingerprint:  print_job.embedded_document_fingerprint,
          created_at:        print_job.created_at,
          updated_at:        print_job.updated_at)
        print_job.update_column(:document_id, document.id)
        source      = Pathname.new(print_job.embedded_document.path)
        destination = Pathname.new(document.file.path)
        if source.exist?
          FileUtils.mkdir_p(destination.parent)
          FileUtils.mv(source, destination)
        end
      end
    end
    remove_index  :print_jobs, :embedded_document_fingerprint
    remove_column :print_jobs, :title
    remove_column :print_jobs, :embedded_document_file_name
    remove_column :print_jobs, :embedded_document_content_type
    remove_column :print_jobs, :embedded_document_file_size
    remove_column :print_jobs, :embedded_document_updated_at
    remove_column :print_jobs, :embedded_document_fingerprint
  end

  def down
    PrintJob.reset_column_information
    Document.reset_column_information
    add_column :print_jobs, :title,                          :string
    add_column :print_jobs, :embedded_document_file_name,    :string
    add_column :print_jobs, :embedded_document_content_type, :string
    add_column :print_jobs, :embedded_document_file_size,    :integer
    add_column :print_jobs, :embedded_document_updated_at,   :datetime
    add_column :print_jobs, :embedded_document_fingerprint,  :string
    PrintJob.where.not(document_id: nil).find_each do |print_job|
      if document = Document.find_by(id: print_job.document_id)
        print_job.update_columns(
          title:                          document.title,
          embedded_document_file_name:    document.file_file_name,
          embedded_document_content_type: document.file_content_type,
          embedded_document_file_size:    document.file_file_size,
          embedded_document_updated_at:   document.file_updated_at,
          embedded_document_fingerprint:  document.file_fingerprint,
          document_id:                    nil)
        source      = Pathname.new(document.file.path)
        destination = Pathname.new(print_job.embedded_document.path)
        if source.exist? && !destination.exist?
          FileUtils.mkdir_p(destination.parent)
          FileUtils.cp(source, destination)
        end
      end
    end
  end
end
