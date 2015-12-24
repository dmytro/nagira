require 'active_model/serialization'
require 'active_model/serializers/xml' # for Hash.to_xml

require 'active_support/inflector'
require 'active_support/inflector/inflections'
require 'active_support/core_ext/hash/slice' # for Hash.slice

require 'json'
require 'yaml'
require 'sinatra/base'
require 'sinatra/reloader'
require 'singleton'

require_relative "../config/defaults"
require_relative "../config/environment"

Dir.glob("#{__dir__}/../{lib,app}/**/*.rb").each { |file| require file }

##
# Main class of Nagira application implementing RESTful API for
# Nagios.
#
class Nagira < Sinatra::Base
  # @!macro  [attach] sinatra.get
  #
  #    @overload get "$1"
  #
  #    @return HTTP response. Hash formatted in the format defined by
  #         requested output type(XML, YAML or JSON).
  #
  #
  #
  # @!macro [new] type
  #     @param [String] :type Type is one of Nagios objects like  hosts, hostgroupsroups, etc.
  #
  # @!macro [new] name
  #       @param [String] :name
  #
  # @!macro [new] hostname
  #   @param [String] :hostname Configured Nagios hostname
  #
  # @!macro [new] service_name
  #   @param [String] :service_name Configured Nagios service for the host
  #
  # @!macro [new] accepted
  #
  #    <b>Accepted output type modifiers:</b>
  #
  # @!macro [new] list
  #
  #     - +/_list+ : Short list of available objects, depending on the
  #       current request context: hosts, services, etc.
  #
  # @!macro [new] state
  #
  #     - +/_state+ - Instead of full status information send only
  #       current state. For hosts up/down, for services OK, Warn,
  #       Critical, Unknown (0,1,2-1)
  #
  # @!macro [new] full
  #
  #     - +/_full+ - Show full status information. When used in
  #       /_status/_full call will display full hoststaus and
  #       servicestatus information for each host.
  #
  #
end
