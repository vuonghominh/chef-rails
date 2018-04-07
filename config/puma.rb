application = "chef-rails"
root_folder = "/home/deployer/www"

pidfile "#{root_folder}/#{application}/shared/tmp/pids/puma.pid"
stdout_redirect "#{root_folder}/#{application}/current/log/puma.error.log", "#{root_folder}/#{application}/current/log/puma.access.log", true

workers Integer(ENV['PUMA_WORKERS']|| 2)
threads Integer(ENV['MIN_THREADS'] || 1), Integer(ENV['MAX_THREADS'] || 16)

preload_app!

rackup      DefaultRackup
bind        ENV['PUMA_SOCKET'] || "unix://#{root_folder}/#{application}/shared/tmp/sockets/#{application}-puma.sock"
environment ENV['RACK_ENV'] || 'development'

worker_timeout = ENV['PUMA_WORKER_TIMEOUT'].to_i + 60

on_worker_boot do
  # worker specific setup
  ActiveSupport.on_load(:active_record) do
    config = ActiveRecord::Base.configurations[Rails.env] ||
                Rails.application.config.database_configuration[Rails.env]
    config['pool'] = ENV['MAX_THREADS'] || 16
    ActiveRecord::Base.establish_connection(config)
    Rails.logger.info "[puma] ActiveRecord::Base.connection.pool = #{ActiveRecord::Base.connection.pool.instance_variable_get('@size')}"
  end
end
