class MoveAttachmentsFaxesToPrintJobs < ActiveRecord::Migration
  def up
    if File.directory?(source)
      if File.directory?(destination)
        FileUtils.mv(Dir.glob("#{source}/*"), destination) && FileUtils.rmdir(source)
      else
        FileUtils.mv source, destination
      end
    end
  end

  def down
    if File.directory?(destination)
      FileUtils.mv(destination, source)
    end
  end

  def attachments_path
    @attachments_path ||= Rails.root.join('storage', Rails.env)
  end

  def source
    @source ||= attachments_path + 'faxes'
  end

  def destination
    @destination ||= attachments_path + 'print_jobs'
  end
end
