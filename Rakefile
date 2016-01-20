require 'fileutils'
require_relative 'app/app'

Dir.glob(File.join(Nagira.root, 'lib', 'tasks','*.rake')).each do |rake|
  load rake
end

def log_user msg
  puts "#{Time.now} -- #{msg.chomp}"
end
