
class Nagira < Sinatra::Base

  disable :protection
  enable :logging


  configure do 
    set :format, :json
  end

  if development?
    require 'sinatra/reloader'
    register Sinatra::Reloader
    also_reload(File.dirname(File.dirname(__FILE__))+"/*.rb")
    also_reload(File.dirname(File.dirname(__FILE__))+"/{app,lib}/**/*.rb")
  end

  ##
  # Development and test environments use local files located in the
  # development tree: ./test/data.
  configure :development, :test do 

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
