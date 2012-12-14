# @title Configuration

# Nagira configuration

## Installation time configuration

File `./config/install.rb` is responsible for configuration Nagira for installation. Values configured in `install.rb` file are used for creating `/etc/init.d/nagira` startup file from ERB template. Values configured here are:

- `:run-as` - UNIX user to run Nagira application. In most cases this would be `nagios`. Please note, directory where Nagira is installed and run from must be accessible to this user.
- `:use_rvm` - Set this to `true` if Ruby on the host running Nagira is installed using RVM, and Ruby use to run Nagira is *not* default Ruby.
- `:rvm` - Version of Ruby for RVM, only used if `:use_rvm` is set to `true`.
- `:log` - Location of the log file for Sinatra log output. Directory for log file should also be accessible and writeable by user, specified in `:run_as`.

#### Example configuration

```ruby
class Nagira < Sinatra::Base
  INSTALL = { 
    :run_as => "nagios",
    :use_rvm => true,
    :rvm => '1.9.3',
    :root => File.dirname( File.dirname(__FILE__)),
    :log => "/var/log/nagira.log"
  }
end
```

## Runtime configuration

Nagira runtime environment configured by adjusting settings in `config/defaults.rb` and `config/environment.rb` files. In most cases `defaults.rb` file should not be changed, usually only editing `environment.rb` file is enough or even this in not required. Most defaults provided in `defaults.rb` and `environment.rb` will work for majority of users and don't need change. Anyway, recomendations below are for configuring Nagira.

File `config/defaults.rb` defines configuration hash `DEFAULT`, it sets attributes `settings`  for Sinatra. Files `defaults.rb` and `environment.rb` use different syntax for configuration: former one uses hash assignment, while latter one uses Sinatra '`set <variable>`' syntax.

#### Per-environment configuration

All settings can be configured either globally or for specific environment (development, production). If configuration block does not have environment name, it is applied for the whole application, otherwise it is only for specific environment.

* Global setting

```ruby
  configure do 
    set :format, :json
  end
```  

* Only for develoment and test

```ruby

  configure :development, :test do 
    set :nagios_cfg, "#{dir}/nagios.cfg"
  end

```

For more details please see Sinatra configuratioin documentation.

### Nagios files location

Location of all Nagios files and data files are automatically detected by parsing `nagios.cfg` file on start. Therefore you only need to point Nagira to that file location. If `Nagira.nagios_cfg` is `nil`, Nagira will use value (Dir.glob) defined in `./lib/ruby-nagios/config/default.rb` file:

```ruby
    DEFAULT = { 
      :nagios_cfg_glob => "/etc/nagios*/nagios.cfg"
    }
```

If you are using some standard distribution of Nagios -- for example RedHat/CentOS RPM or Debian/Ubuntu dpkg -- chances are your `nagios.cfg` file is in `/etc/nagios3` or `/etc/nagios` directory. In this case Nagira will be OK with default configuration.

However, if this is not the case, please set file location as in the example below.

#### Example configuration

Configure location of main configuration file for production:

```ruby
    configure :production do
       set :nagios_cfg, "/usr/local/nagios/etc/nagios.cfg"
    end
```

### Default HTTP output format

Nagira supports multiple output formats: XML, JSON, YAML. Default output format is defined by `settings.format` Sinatra attribute. It is configured in `config/defaults.rb` as

```ruby
    set :format, :json
```

### File parsing time interval

By default Nagios data files are not parsed on each HTTP request, instead they are parsed only if file was modified more than N seconds ago. This is configured by Sinatra's setting `min_parse_interval`.


```ruby
   set :min_parse_interval, 60
```

## Verifying your configuration

There is a RSpec file that allows to check your current configuration. It checks whether your Nagios files exist and can be parses by the Nagira.

Configurarion checker is environment dependent. To check files for particular environment run check as:

```
    RACK_ENV=<environment> rspec -fd spec/00_configuration_spec.rb
```

In development and test (by default) it will check presence of files under ./test/data subdirectory. In production it checks actual Nagios files and validity of files in your Nagios installation.

With no errors check should produce output as following:

```

  Nagira
    nagios.cfg file
      should exist
      should be parseable
      parsed file
        should have PATH to objects file
        should have PATH to status file
        objects file
          should exist
          should be parseable
        status file
          should exist
          should be parseable

  Finished in 0.1727 seconds

```
