
require 'erb'
require 'fileutils'
require_relative 'lib/nagira'
require_relative 'config/install'

def log_user msg
  puts "#{Time.now} -- #{msg.chomp}"
end

namespace :doc do
  
  desc 'Generate YARD documentation'
  task :yard do
    sh 'yardoc'
  end

#   namespace :yard do
#     desc 'Generate YARD documentation for github web page'
#     task :github do
#       sh 'yardoc --output-dir ../dmytro.github.com/nagira/doc'
#     end
#   end

end

namespace :config do

  @nagira_root   = File.dirname File.expand_path __FILE__ # Where Nagira installed
  @nagira_config = File.join(@nagira_root, 'config')      # Config directory of Nagira installation

  target_os = nil

  %x{ sherlock }.split($\).each do |line|
    next unless line =~ /^FAMILY=/
    l,target_os = line.chomp.split '='
    target_os = target_os.chomp.strip.to_sym
  end


  desc "Create Nagira configuration, allow start on boot and start it"
  task :all => [:config, :chkconfig, :start]

  def test?
    ENV['RAKE_ENV'] == 'test'
  end

  etc     = test? ? 'tmp/etc' : "/etc"
  init_d  = File.join etc, 'init.d'

  directory etc
  directory init_d


  desc "Create configuration for Nagira in /etc"
  task :config => [:init_d, :defaults]


  #desc "Install /etc/init.d startup file for Nagira"
  task :init_d => init_d do
    src = File.join(@nagira_config, 'nagira.init_d')
    dst = "#{init_d}/nagira"

    FileUtils.copy  src, dst
    FileUtils.chown 0, 0, dst unless test?
    FileUtils.chmod 0755, dst

    log_user "Installed startup file at #{dst}"
  end

  #desc "Install defaults file for Nagira service in /etc"
  task :defaults do 
    src = File.join(@nagira_config, 'nagira.defaults')
    dst = case target_os
          when :rh
            '/etc/sysconfig/nagira'
          when :debian
            '/etc/default/nagira'
          else
            log_user "Unknown or unsupported target OS: #{target_os}"
            log_user "Skipped defaults file installation"
            next
          end
    
    FileUtils.copy src, dst
    FileUtils.chown 0, 0, dst unless test?
    FileUtils.chmod 0644, dst

    log_user "    Installed defaults file for Nagira in #{dst}."
    log_user "    You might want to tune some of the variables."
  end

  desc "Start Nagira API service"
  task :start => [:init_d, :defaults] do
    sh "/etc/init.d/nagira start"
  end
  
  desc "Configure Nagira to start on system boot"
  task :chkconfig => [:init_d, :defaults] do

    log_user "Configuring Nagira to start at boot"
    case target_os
    when :rh
      sh "/sbin/chkconfig --add nagira"
      sh "/sbin/chkconfig nagira on"
    when :debian
      sh "/usr/sbin/update-rc.d nagira defaults"
    else
      abort "Unknown or unsupported target OS: #{target_os}"
    end
    log_user "[OK]"
  end

end


