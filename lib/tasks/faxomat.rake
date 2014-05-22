namespace :faxomat do
  desc 'Import fax jobs from WiCoRIS.'
  task :import do
    Dir.glob('/Library/FileMaker Server/Data/Documents/2014-*.JSON').each do |file|
      puts file
      Importer.new(file).run
    end
  end

  desc 'Deliver all undelivered faxes.'
  task :deliver do
    puts Fax.deliver
  end

  desc 'Synchronize fax (print job) states from CUPS.'
  task :update do
    Fax.update_states
  end

  desc 'Perform all faxomat tasks: import, deliver and update.'
  task :run => [:import, :deliver, :update]
end
