namespace :faxomat do
  def build_logger
    logger = ActiveSupport::Logger.new(STDOUT)
    logger.formatter = proc do |severity, datetime, progname, msg|
      "#{datetime.iso8601} [#{severity}] #{msg}\n"
    end
    logger
  end

  desc 'Update status of active prints.'
  task :check => :environment do
    puts "#{Time.zone.now.iso8601} Updating active print jobs on #{Rails.env}..."
    Print.update_active
  end

  desc 'Start the scheduler to run periodic tasks.'
  task :scheduler => :environment do |task|
    scheduler = Rufus::Scheduler.new
    logger = build_logger

    scheduler.every '5m' do
      logger.info "#{task.name}: Updating active print jobs..."
      Print.update_active
    end

    scheduler.every '1h' do
      deleted_exports =
        Export.without_deleted.where('created_at < ?', 3.months.ago).destroy_all
      count = deleted_exports.count
      noun = Export.model_name.human(count: count)
      unless count.zero?
        deleted_exports.each do |e|
          logger.debug {
            "#{task.name}: Lösche #{e.model_name.human} #{e.id} (#{e.destination})"
          }
        end
      end
      logger.info "#{task.name}: #{count} #{noun} gelöscht"
    end

    scheduler.join
  end

  desc 'Delete old exports.'
  task :delete_old_exports => :environment do |task|
    logger = build_logger
    deleted_exports =
      Export.without_deleted.where('created_at < ?', 3.months.ago).destroy_all
    count = deleted_exports.count
    noun = Export.model_name.human(count: count)
    unless count.zero?
      deleted_exports.each do |e|
        logger.debug {
          "#{task.name}: #{e.model_name.human} #{e.id} (#{e.destination})"
        }
      end
    end
    logger.info "#{task.name}: #{count} #{noun} gelöscht"
  end
end
