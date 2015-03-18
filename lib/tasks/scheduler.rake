namespace :scheduler do
  desc 'Run the scheduler.'
  task run: :environment do
    scheduler = Rufus::Scheduler.new
    logger = Logger.new(STDOUT)

    scheduler.every '5m' do
      logger.info 'Checking faxes...'
      Fax.check
    end

    scheduler.join
  end
end
