namespace :faxomat do
  #desc 'Import fax jobs from WiCoRIS.'
  task :import do
    Dir.glob('/Library/FileMaker Server/Data/Documents/2014-*.JSON').each do |file|
      puts file
      Importer.new(file).run
    end
  end

  #desc 'Deliver faxes.'
  task :deliver do
    Fax.includes(:deliveries).where(deliveries: {fax_id: nil}).each do |fax|
      puts fax.title
      fax.deliver!
    end
  end

  #desc 'Update delivery states.'
  task :verify do
    Delivery.update_print_job_states
  end

  desc 'Send faxes like a maniac.'
  task :run => [:import, :deliver, :verify]
end
