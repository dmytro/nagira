
require 'active_support' # for Hash.extract!
require 'json'
require 'yaml'
require 'active_model/serialization'
require 'active_model/serializers/xml' # for Hash.to_xml
require 'sinatra'

$: << File.dirname(__FILE__) << File.dirname(File.dirname(__FILE__))

require 'config/defaults'
#
# environment file must go after default, some settings override
# defaults.
#
require 'config/environment'
require 'nagira/nagios'

