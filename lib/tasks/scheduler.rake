namespace :scheduler do
  desc 'Run the scheduler.'
  task run: :environment do
    scheduler = Rufus::Scheduler.new

    scheduler.every '5m' do
      Rails.logger.info 'Checking faxes...'
      Fax.check
    end

    scheduler.join
  end
end
