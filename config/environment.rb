

configure :development do 
  set :nagios_cfg, File.expand_path(File.dirname(__FILE__) + '/../test/data/nagios.cfg')
end


# configure :production do
#   # If your nagios.cfg file is in 'standard' location (in RH and
#   # Debian it usially installed under /etc/nagios(3)?) you don't need
#   # to define nagios_cfg.
#   set :nagios_cfg, nil
# end

