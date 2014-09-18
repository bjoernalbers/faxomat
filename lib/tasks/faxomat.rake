namespace :faxomat do
  desc 'Deliver all deliverable faxes.'
  task :deliver => :environment do
    puts "#{Time.zone.now.iso8601} Delivering faxes in #{Rails.env}."
    Fax.deliver
  end

  desc 'Check currently being delivered fax.'
  task :check => :environment do
    puts "#{Time.zone.now.iso8601} Checking fax in #{Rails.env}."
    Fax.check
  end
end
