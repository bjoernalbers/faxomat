namespace :faxomat do
  desc 'Update status of active print_jobs.'
  task :check => :environment do
    puts "#{Time.zone.now.iso8601} Updating active print jobs on #{Rails.env}..."
    Printer.update_active_print_jobs
  end
end
