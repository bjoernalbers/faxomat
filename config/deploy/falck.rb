set :rails_env, 'production' 
set :user, 'admin'
server '192.168.64.61', # Yoda.local
  user: fetch(:user),
  roles: %w(web app db)
