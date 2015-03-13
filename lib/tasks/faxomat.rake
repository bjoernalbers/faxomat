namespace :faxomat do
  desc 'Update status of active faxes.'
  task :check => :environment do
    puts "#{Time.zone.now.iso8601} Checking fax in #{Rails.env}."
    Fax.check
  end
end
