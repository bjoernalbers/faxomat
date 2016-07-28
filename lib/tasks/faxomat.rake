namespace :faxomat do
  desc 'Update status of active prints.'
  task :check => :environment do
    puts "#{Time.zone.now.iso8601} Updating active print jobs on #{Rails.env}..."
    Print.update_active
  end

  desc 'Export all report print jobs addressing EVK fax numbers.'
  task :evkexport => :environment do |task|
    start_time = Time.zone.now
    logger = ActiveSupport::Logger.new('log/evkexport.log')
    logger.formatter = proc do |severity, datetime, progname, msg|
      "[#{severity}] #{msg}\n"
    end
    logger.info "#{task.name} gestartet um #{start_time}"
    documents = Document.exportable_to_evk
    logger.info "Exportiere #{documents.count} Dokumente..."
    documents.find_each do |document|
      unless directory = Directory.default
        logger.error "Kein Standardordner gefunden. Bitte anlegen!"
        raise 'Oh, Kacke!'
      end
      export = document.exports.new(directory: directory)
      if export.save
        logger.info "Dokument #{document.id} exportiert nach \"#{export.destination}\""
      else
        logger.warn "Dokument #{document.id} NICHT exportiert: #{export.errors.full_messages.join(", ")}"
      end
    end
    logger.info "#{task.name} beendet um #{Time.zone.now} in #{ActionController::Base.helpers.distance_of_time_in_words_to_now(start_time)}"
  end
end
