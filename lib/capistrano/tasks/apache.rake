namespace :apache do
  WEBAPP_NAME = 'de.bjoernalbers.faxomat' # Do not change!

  def apache_dir
    @apache_dir ||= Pathname.new('/Library/Server/Web/Config/apache2')
  end

  def webappctl
    '/Applications/Server.app/Contents/ServerRoot/usr/sbin/webappctl'
  end

  desc 'Setup Launch Daemons'
  task :setup do
    on roles(:app) do
      template2 'apache/webapp.plist.erb',
        apache_dir.join('webapps', WEBAPP_NAME + '.plist')
      template2 'apache/webapp.conf.erb',
        apache_dir.join(WEBAPP_NAME + '.conf')
    end
  end

  desc 'Stop webapp'
  task :stop => :setup do
    on roles(:app) do
      execute :sudo, webappctl, :stop, WEBAPP_NAME
    end
  end

  desc 'Start webapp'
  task :start => :setup do
    on roles(:app) do
      execute :sudo, webappctl, :start, WEBAPP_NAME
    end
  end

  def template2(from, to)
    tmp = Pathname.new('/tmp').join(File.basename(to))
    template_path = File.expand_path("../../templates/#{from}", __FILE__)
    template = ERB.new(File.new(template_path).read).result(binding)
    upload! StringIO.new(template), tmp
    execute :sudo, :mv, tmp, to
    execute :sudo, :chown, "root:wheel #{to}"
    execute :sudo, :chmod, "644 #{to}"
  end

end
