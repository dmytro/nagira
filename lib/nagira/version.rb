require 'sinatra'
class Nagira < Sinatra::Base
  VERSION  = File.read(File.expand_path(File.dirname(__FILE__)) + '/../../version.txt').strip
end
