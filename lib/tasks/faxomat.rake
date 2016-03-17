namespace :faxomat do
  desc 'Update status of active print_jobs.'
  task :check => :environment do
    puts "#{Time.zone.now.iso8601} Updating active print jobs on #{Rails.env}..."
    Printer.update_active_print_jobs
  end

  desc 'Export all report print jobs addressing EVK fax numbers.'
  task :evkexport => :environment do
    dir = Rails.root.join('storage', Rails.env.to_s, 'evkexport')
    unless File.directory?(dir)
      FileUtils.mkdir(dir, verbose: true)
    end
    PrintJob.where('fax_number LIKE ?', '02941671%').where.not(report: nil).
      find_each do |fax|
        patient = fax.report.patient
        source = fax.document.path
        fingerprint = Digest::MD5.file(source).hexdigest
        filename = [
          patient.last_name,
          patient.first_name,
          patient.date_of_birth.strftime('%Y-%m-%d'),
          fingerprint[0..3]
        ].join('_') + '.pdf'
        destination = dir + filename
        unless File.exists?(destination)
          FileUtils.cp(source, destination, verbose: true)
        end
        if Rails.env.production?
          system "rsync -rv '#{dir}/' rgp@sauron:'/Shared\ Items/evkexport'"
        end
    end
  end
end
