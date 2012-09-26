source 'http://rubygems.org'

gem 'sinatra', '>= 1.3.1'

#
# RSpec modules should be in all environments - to be able to test prod config
# too
# 
gem 'rspec-core'
gem 'rspec-mocks'
gem 'rspec-expectations'

group :development,:test do 
  gem 'sinatra-contrib', '>= 1.3.1'
  gem 'rake'
  gem 'yard', "~> 0.8"
  gem "growl", "~> 1.0.3"
  gem "guard-brakeman", "~> 0.5.0"
  gem "guard-rspec", "~> 1.2.1"
end

# for Hash.extract!
gem 'activesupport'


#  Active_Model required for this:
# 'active_model/serialization'
#  'active_model/serializers/xml' # for Hash.to_xml
gem 'activemodel'

gem 'json'
