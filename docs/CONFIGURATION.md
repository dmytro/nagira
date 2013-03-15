# @title Configuration

# Nagira configuration

## Run-time configuration

Nagira run-time environment configured by adjusting settings in `config/defaults.rb` and `config/environment.rb` files. In most cases `defaults.rb` file should not be changed, usually only editing `environment.rb` file is enough or even this in not required. Most defaults provided in `defaults.rb` and `environment.rb` will work for majority of users and don't need change. Anyway, recommendations below are for configuring Nagira.

File `config/defaults.rb` defines configuration hash `DEFAULT`, it sets attributes `settings`  for Sinatra. Files `defaults.rb` and `environment.rb` use different syntax for configuration: former one uses hash assignment, while latter one uses Sinatra '`set <variable>`' syntax.

#### Environment variables

See comments in `config/nagira.defaults` file for environment variables that Nagira understands. This file is copied to system defaults area during installation. Bu adjusting values in this file you can change Nagira installation.

The same variables can be set in the shell if you are using Nagira on command line. 

Some of the configuration examples given below can be changed either in source of Nagira or by environment variable.

#### Per-environment configuration

All settings can be configured either globally or for specific environment (development, production). If configuration block does not have environment name, it is applied for the whole application, otherwise it is only for specific environment.

* Global setting

```ruby
  configure do 
    set :format, :json
  end
```  

* Only for development and test

```ruby

  configure :development, :test do 
    set :nagios_cfg, "#{dir}/nagios.cfg"
  end

```

For more details please see Sinatra configuration documentation.

### Nagios files location

Location of all Nagios files and data files are automatically detected by parsing `nagios.cfg` file on start. Therefore you only need to point Nagira to this file location. Value for the search directories is set in `ruby-nagios` module defaults (starting from Nagira version > 0.2.1) and it is:

```ruby
    :nagios_cfg_glob => ENV['NAGIOS_CFG_FILE'] || 
    [
     "/etc/nagios*/nagios.cfg", 
     "/usr/local/nagios/etc/nagios.cfg"
    ]
```

If you are using some standard distribution of Nagios -- for example RedHat/CentOS RPM or Debian/Ubuntu dpkg -- chances are your `nagios.cfg` file is in `/etc/nagios3` or `/etc/nagios` directory. In this case Nagira will be OK with default configuration.

However, if this is not the case, please set file location as in the example below or override by setting variable `NAGIOS_CFG_FILE` in the shell.

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

By default Nagios data files are not parsed on each HTTP request, instead they are parsed only if file was modified more than N seconds ago. This is configured by Sinatra's setting `ttl`.


```ruby
    DEFAULT = {
        ...
        :ttl => 60
        }
```

**Note** `:ttl` value can only be set in `config/defaults.rb` but not in `config/environment.rb`

### Background parsing

When on user request Nagira needs to parse `status.dat` file (when `:ttl` time passed) for large files there could be significant delay in sending data back to user. On average these delays will happen every `:min_parse_interval` seconds. 

If you want to prevent such delays responding to user requests, it is possible to start background loading and parsing `status.dat` file on regular intervals in separate thread.

For this set value of `:start_background_parser` to `true` and `:ttl` to at least 1 sec (or more).

```ruby
    DEFAULT = {
        ...
        :ttl => 60
        :start_background_parser => true
        }
```

**Note** Same as `:ttl` above value of `:start_background_parser` can only be set in `config/defaults.rb` but not in `config/environment.rb`


## Verifying your configuration

There is a RSpec file that allows to check your current configuration. It checks whether your Nagios files exist and can be parses by the Nagira.

Configuration checker is environment dependent. To check files for particular environment run check as:

```
    RACK_ENV=<environment> rspec -fd spec/00_configuration_spec.rb
```

In development and test (by default) it will check presence of files under ./test/data sub-directory. In production it checks actual Nagios files and validity of files in your Nagios installation.

With no errors check should produce output as following:

```
    
      $ bundle exec rspec --format doc  spec/00_configuration_spec.rb
      [2013-03-15 17:02:06 +0900] -- Starting Nagira apllication
      [2013-03-15 17:02:06 +0900] -- Version 0.2.5
      [2013-03-15 17:02:06 +0900] -- Running in development environment
      [2013-03-15 17:02:06 +0900] -- Using nagios config file: /Users/dmytro/Development/nagira/test/data/nagios.cfg
      [2013-03-15 17:02:06 +0900] -- Using nagios status file: /Users/dmytro/Development/nagira/test/data/status.dat
      [2013-03-15 17:02:06 +0900] -- Using nagios objects file: /Users/dmytro/Development/nagira/test/data/objects.cache
      [2013-03-15 17:02:06 +0900] -- Using nagios commands file: /tmp/nagios.cmd
      
      Configuration
        nagios.cfg
            should exist ["/Users/dmytro/Development/nagira/test/data/nagios.cfg"]
            should be parseable
            parsing nagios.cfg file
              should have PATH to objects file
              should have PATH to status file
        data files
            Nagios::Status
              should exist ["/Users/dmytro/Development/nagira/test/data/status.dat"]
              should be parseable
            Nagios::Objects
              should exist ["/Users/dmytro/Development/nagira/test/data/objects.cache"]
              should be parseable
      
      Finished in 0.12154 seconds
      8 examples, 0 failures
      
```
      
