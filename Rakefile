require 'fileutils'
require_relative 'lib/nagira'

$nagira_root   = File.dirname File.expand_path __FILE__ # Where Nagira installed

Dir.glob(File.join($nagira_root, 'lib', 'tasks','*.rake')).each do |rake|
  load rake
end

def log_user msg
  puts "#{Time.now} -- #{msg.chomp}"
end




