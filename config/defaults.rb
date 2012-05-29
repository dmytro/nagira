
##
# This file sets some constants, that are used as defaults in Nagira
# application. Instead of changin this please modify
# config/environment.rb file to match your requirements. Settings in
# environment.rb file override these defaults

DEFAULT = {
   
  format_extensions: '\.(json|yaml|xml)$', #  Regex for available
                                           #  formats: xml, json, yaml

  format: :xml, # default format for application to send output, if
                # format is not specified


  nagios_cfg_glob: '/etc/nagios*/nagios.cfg', # Dir.glob pattern to
                                              # search for nagios.cfg
                                              # file buy default

  nagios_cfg: nil # No path to file by default
}

# For every key in the DEFAULT hash create setting with the same name
# and value. Values can be overrriden in environment.rb file if
# required.

configure do
  DEFAULT.each do |key,val|
    set key,val
  end
end
