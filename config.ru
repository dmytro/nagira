require 'rubygems'
require 'sinatra'
require 'app.rb'


path = '' # set the root path of your app here. e.g. /var/www/username/somesite
 
set :root, path
set :views, path + '/views'
set :public, path + '/public'
set :environment, :production
set :raise_errors, true 
 
# always put this line last so that all of your settings are properly loaded before sinatra is booted up
run Sinatra::Application
