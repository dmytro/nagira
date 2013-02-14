

##
# This file sets some constants, that are used as defaults in Nagira
# application. Instead of changing this please modify
# config/environment.rb file to match your requirements. Settings in
# environment.rb file override these defaults.
#
# Exception is ::DEFAULT[:min_parse_interval] which i not overriden by
# environment.rb and should be changed here.


DEFAULT = {
   
  format_extensions: '\.(json|yaml|xml)$', #  Regex for available
                                           #  formats: xml, json, yaml

  format: :xml, # default format for application to send output, if
                # format is not specified


  # No path to file configuration file by default. Main nagios config
  # is defined by +nagios_cfg_glob+ or by Sintra's
  # +settings.nagios_cfg+ variable. 
  #
  # status_cfg and objects_cfg are defined by parsing of nagios_cfg
  # file. Sinatra's setting override parsed values.
  nagios_cfg: nil, 
  status_cfg: nil,
  objects_cfg: nil,
  command_file: nil,
  
  ##
  # min_parse_interval used in Nagios::TimedParse module - extension
  # to Nagios modules.
  #
  # @see Nagios::TimedParse
  #
  # Set some minimum interval for re-parsing of the status file: even
  # if file changes often, we do not want to parse it more often, then
  # this number of seconds. To disable timed parsing, set
  # min_parse_interval to 0 or negative number.
  
  min_parse_interval: 5,
  
  ##
  # start_background_parser used in Nagios::BackgroundParse class.
  #
  # @see Nagios::BackgroundParse
  #
  # If set to true then use background parser. This will prevent
  # parsing delays on client request. Background parserruns on
  # intervals slightly shorter than `min_parse_interval` to ensure
  # that data are always updated. So, `min_parse_interval` should be
  # larger than 1.
  #
  start_background_parser: true
}

require 'sinatra'
class Nagira < Sinatra::Base

##
# For every key in the DEFAULT hash create setting with the same name
# and value. Values can be overrriden in environment.rb file if
# required.
# @method define_methods_for_defaults
configure do
  ::DEFAULT.each do |key,val|
    set key,val
  end
end


end
