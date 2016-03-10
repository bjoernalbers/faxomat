class AddDocumentFingerprintToPrintJobs < ActiveRecord::Migration
  def up
    add_column :print_jobs, :document_fingerprint, :string
    PrintJob.find_each do |print_job|
      path = print_job.document.path 
      if path && File.exists?(path)
        fingerprint = Digest::MD5.file(path).hexdigest
        print_job.update_column(:document_fingerprint, fingerprint)
      end
    end
  end

  def down
    remove_column :print_jobs, :document_fingerprint
  end
end
