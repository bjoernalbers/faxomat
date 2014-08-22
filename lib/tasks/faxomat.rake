namespace :faxomat do
  desc 'Deliver all undelivered faxes.'
  task :deliver => :environment do
    puts "Delivering faxes in #{Rails.env}..."
    puts Fax.deliver
  end

  desc 'Synchronize fax (print job) states from CUPS.'
  task :update => :environment do
    puts "Updating fax states in #{Rails.env}."
    Fax.update_states
  end

  desc 'Import and deliver fax jobs from WiCoRIS.'
  task :run => [:update, :deliver]
end
