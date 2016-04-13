class DeleteAttachmentDirsForPrintJobsAndLetters < ActiveRecord::Migration
  def up
    %w(letters print_jobs).each do |dir|
      destination = Rails.root.join('storage', Rails.env, dir)
      if destination.exist?
        FileUtils.rm_r(destination, secure: true, verbose: true)
      end
    end
  end

  def down
    # Nothing to do here...
  end
end
