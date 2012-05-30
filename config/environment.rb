

configure :development do 

  dir = File.expand_path(File.dirname(__FILE__) + '/../test/data/')

  set :nagios_cfg => "#{dir}/nagios.cfg",
      :status_cfg => "#{dir}/status.dat",
      :object_cfg => "#{dir}/objects.cache"
end


# configure :production do
#   # If your nagios.cfg file is in 'standard' location (in RH and
#   # Debian it usially installed under /etc/nagios(3)?) you don't need
#   # to define nagios_cfg.
#   set :nagios_cfg, nil
# end

