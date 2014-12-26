require 'fileutils'
require_relative 'lib/nagira'

Dir.glob(File.join(Nagira.root, 'lib', 'tasks','*.rake')).each do |rake|
  load rake
end

def log_user msg
  puts "#{Time.now} -- #{msg.chomp}"
end
