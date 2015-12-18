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

class Nagira < Sinatra::Base

  VERSION  = File.read("#{__dir__}/../version.txt").strip
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

Dir.glob("#{__dir__}/../{lib,app}/**/*.rb").each { |file| require file }
