namespace :debug do
  require 'fileutils'

  #
  # These are default configured files.
  #
  files = %w{ /etc/init.d/nagira /etc/sysconfig/nagira /etc/default/nagira /var/log/nagios/nagira.log }
  files += Dir.glob(
                    [
                      "/etc/nagios*/nagios.cfg",
                      "/usr/local/nagios/etc/nagios.cfg"
                      ]
                    )
  files << ENV['NAGIOS_CFG_FILE'] if ENV['NAGIOS_CFG_FILE']

  desc "Collect debugging information: config files, permissions etc."
  task :collect do

    output = "nagira-debug-output.#{Time.now.to_s.gsub(' ', '_')}.tgz"
    os_info = %x{ $GEM_HOME/bin/sherlock 2>&1 }
    permissions = %x{  ls -liL #{files.join ' '} 2>&1 }
    environment = %x{ (set; export) 2>&1 }

    puts "Creating file #{output}. Please send this file for investigation."

    Dir.mktmpdir {  |dir|

      $stdout.reopen("#{dir}/stdout.txt", "w")
      require_relative '../../lib/nagira.rb'
      require_relative '../../lib/app.rb'
      #
      # These files from parsed config.
      #
      files << $nagios[:config].path
      files << $nagios[:status].path
      files << $nagios[:objects].path

      open("#{dir}/sherlock.txt", "w")    { |f| f.puts os_info }
      open("#{dir}/permissions.txt", "w") { |f| f.puts permissions }
      open("#{dir}/environment.txt", "w") { |f| f.puts environment }

      files.each do |ff|
        FileUtils.cp(ff, "#{dir}/#{ff.gsub('/','_')}") if File.exist? ff
      end

      %x{ tar cfz #{output} #{dir} 1>&2 }
    }
  end
end
