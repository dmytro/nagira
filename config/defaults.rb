

##
# This file sets some constants, that are used as defaults in Nagira
# application. Instead of changing this please modify
# config/environment.rb file to match your requirements. Settings in
# environment.rb file override these defaults.
#
# Exception is ::DEFAULT[:ttl] which is not overriden by environment.rb
# and should be changed here.

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
  # ttl used in Nagios::TimedParse module - extension
  # to Nagios modules.
  #
  # @see Nagios::TimedParse
  #
  # Set some minimum interval for re-parsing of the status file: even
  # if file changes often, we do not want to parse it more often, then
  # this number of seconds. To disable timed parsing, set
  # ttl to 0 or negative number.

  ttl: (ENV['NAGIRA_TTL'] && ENV['NAGIRA_TTL'].to_i) || 5,

  ##
  # start_background_parser used in Nagios::BackgroundParse class.
  #
  # @see Nagios::BackgroundParse
  #
  # If set to true then use background parser. This will prevent
  # parsing delays on client request. Background parserruns on
  # intervals slightly shorter than `ttl` to ensure that data are
  # always updated. So, `ttl` should be larger than 1.
  #
  start_background_parser: (ENV['NAGIRA_BG_PARSING'] != '0'),

  ##
  # By default hostname regular expression accepts alpha-numerics,
  # dashes and dots, as specified by http://tools.ietf.org/html/rfc952
  # for hostnames. Extended to accept dots in the middle for FQHN's.
  #
  #
  # - default: '\w([\w\-\.]+)?\w'
  # - simple hostname: '\w([\w\-]+)?\w'
  # - allow space in hostname: '\w([\w\-\.(%20)]+)?\w'
  #
  # Explanation regarding spaces:
  # ---------------------------------
  #
  # Nagios works OK with hostnames with spaces. This is against RFC's
  # and can't really used for real hosts, but for aggregated checks
  # (like cluster name for example), you might want to consider this
  # option.

  hostname_regex: ENV['NAGIOS_HOST_CUSTOM_REGEX'] || '\w([\w\-\.]+)?\w'

}

# require 'sinatra'
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
