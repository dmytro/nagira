require 'rubygems'
require 'sinatra'
$: << File.dirname(__FILE__) + '/lib/' << File.dirname(__FILE__) + '/app/'
require 'app'
Nagira.run!
