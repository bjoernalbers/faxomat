set :rails_env, 'production' 
set :user, 'rgp'
server 'frodo.intern.radiologie-lippstadt.de', # a.k.a. faxomat
  user: fetch(:user),
  roles: %w(web app db)
