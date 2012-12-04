
require 'erb'
require_relative 'lib/nagira'
require_relative 'config/install'

namespace :doc do
  
  desc 'Generate YARD documentation'
  task :yard do
    sh 'yardoc'
  end

  namespace :yard do
    desc 'Generate YARD documentation for github web page'
    task :github do
      sh 'yardoc --output-dir ../dmytro.github.com/nagira/doc'
    end
  end

end

namespace :config do

  desc "Create Nagira configuration files and start it"
  task :all => [:init_d, :service]

  def test?
    ENV['RAKE_ENV'] == 'test'
  end

  etc = if test?
          'tmp/etc'
        else
          "/etc"
        end

  directory etc
  directory "#{etc}/init.d"

  desc "Install /etc/init.d startup file for Nagira"
  task :init_d => "#{etc}/init.d" do

    @nagira_root = File.dirname File.expand_path __FILE__

    src = File.join(File.dirname(__FILE__), 'config', 'nagira.init_d.erb')
    dst = "#{etc}/init.d/nagira"

    File.open(dst, 'w') do |f|
      f.chown 0,0 unless test?
      f.chmod 0755
      f.print ERB.new(File.read(src)).result(binding)
      f.close
    end
  end

  desc "Start Nagira API service"
  task :service => :chkconfig do
    sh "/etc/init.d/nagira start"
  end

  task :chkconfig => :init_d do
    sh "/usr/sbin/update-rc.d nagira defaults"
  end

end


