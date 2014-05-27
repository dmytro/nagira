class Nagira < Sinatra::Base

  disable :protection
  enable :logging

  set :port, ENV['NAGIRA_PORT'].to_i if ENV['NAGIRA_PORT']
  set :bind, ENV['NAGIRA_BIND'] if ENV['NAGIRA_BIND']
  set :root, File.dirname(File.dirname(__FILE__))

  configure do
    set :server, %w[puma thin webrick]
    set :format, :json
  end

  require 'sinatra/reloader'  if development?

  ##
  # Development and test environments use local files located in the
  # development tree: ./test/data.
  configure :development, :test do
    register Sinatra::Reloader
    also_reload("#{root}/*.rb")
    also_reload("#{root}/{config,app,lib}/**/*.rb")

    dir = File.expand_path(File.dirname(__FILE__) + '/../test/data/')

    set :nagios_cfg, "#{dir}/nagios.cfg"
    set :status_cfg, "#{dir}/status.dat"
    set :objects_cfg, "#{dir}/objects.cache"
    set :command_file, "/tmp/nagios.cmd"

    set :show_exceptions, false
  end


# configure :production do
#   # If your nagios.cfg file is in 'standard' location (in RH and
#   # Debian it usially installed under /etc/nagios(3)?) you don't need
#   # to define nagios_cfg.
#   set :nagios_cfg, nil
# end

end
