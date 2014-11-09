require 'active_model/serialization'
require 'active_model/serializers/xml' # for Hash.to_xml

require 'active_support/inflector'
require 'active_support/inflector/inflections'
require 'active_support/core_ext/hash/slice' # for Hash.slice

require 'json'
require 'yaml'
require 'sinatra'
require 'sinatra/reloader'

$: << File.dirname(__FILE__) << File.dirname(File.dirname(__FILE__))

require 'config/defaults'

require "app/routes/get/config"
require "app/routes/get/objects"
require "app/routes/get/status"


#
# environment file must go after default, some settings override
# defaults.
#
require 'config/environment'
require 'nagira/nagios'

class Nagira < Sinatra::Base

  VERSION  = File.read(File.expand_path(File.dirname(__FILE__)) + '/../version.txt').strip
  GITHUB   = "http://dmytro.github.com/nagira/"

  ##
  # When this prefix added to routes convert output to ActiveResource
  # compatible format (basically Array instead of Hash).
  #
  AR_PREFIX = "/ar"

  # Get all routes that Nagira provides.
  def api
    api = { }

    param_regex = Regexp.new '\(\[\^\\\\\/\?\#\]\+\)'
    Nagira.routes.keys.each do |method|
      api[method] ||= []
      Nagira.routes[method].each do |r|
        path = r[0].inspect[3..-3]
        r[1].each do |parm|
          path.sub!(param_regex,":#{parm}")
        end
        path.gsub!('\\','')
        api[method] << path unless path.empty?
      end
    end
    api
  end
end
