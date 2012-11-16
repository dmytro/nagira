
require 'erb'

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

namespace :app do 


  etc = '/etc'
  
  def test?
    ENV['RAKE_ENV'] == 'test'
  end
  
  if test?
    #NAGIOS[:target_dir] = 'tmp/etc'
    etc = 'tmp/etc'
  end


  desc "Create Nagira configuration files"
  task :configure => ["app:nagira:init_d", "app:nagira:service"]

  directory etc

  namespace :nagira do 
    
    directory "#{etc}/init.d"

    desc "Install /etc/init.d startup file for Nagira"
    task :init_d => "#{etc}/init.d" do 

      src = File.join(File.dirname(__FILE__), 'config', 'nagira.init_d.erb')
      dst = "#{etc}/init.d/nagira"

      File.open(dst, 'w') do |f|
        f.chown 0,0 unless test?
        f.chmod 755
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
end
