namespace :launchd do
  desc 'Setup Launch Daemons'
  task :setup do
    on roles(:app) do
      template 'unicorn_launchd.erb', '/tmp/de.faxomat.unicorn.plist'
      template 'rake_launchd.erb', '/tmp/de.faxomat.rake.plist'
      execute :sudo, :mv, '/tmp/de.faxomat.unicorn.plist /Library/LaunchDaemons/de.faxomat.unicorn.plist'
      execute :sudo, :mv, '/tmp/de.faxomat.rake.plist /Library/LaunchDaemons/de.faxomat.rake.plist'
    end
  end

  desc 'Load Launch Daemons'
  task :load do
    on roles(:app) do
      execute :sudo, :launchctl, 'load -w /Library/LaunchDaemons/de.faxomat.unicorn.plist'
      execute :sudo, :launchctl, 'load -w /Library/LaunchDaemons/de.faxomat.rake.plist'
    end
  end

  desc 'Unload Launch Daemons'
  task :unload do
    on roles(:app) do
      execute :sudo, :launchctl, 'unload -w /Library/LaunchDaemons/de.faxomat.unicorn.plist'
      execute :sudo, :launchctl, 'unload -w /Library/LaunchDaemons/de.faxomat.rake.plist'
    end
  end
end

def template(from, to)
  template_path = File.expand_path("../../templates/#{from}", __FILE__)
  template = ERB.new(File.new(template_path).read).result(binding)
  upload! StringIO.new(template), to

  execute :sudo, :chmod, "644 #{to}"
  execute :sudo, :chown, "root:wheel #{to}"
end
