listen '0.0.0.0:3000'
worker_processes 2
timeout 30
pid '/tmp/unicorn.pid'

rails_root_dir = File.expand_path(File.join(File.dirname(__FILE__), '..'))

working_directory rails_root_dir
