# @title: Legacy installation

Note: for instalaltion instructions using gem-packaged Nagira please see {file:INSTALL.md}

## Installation procedure

- Clone from Github:

     git clone --recursive git@github.com:dmytro/nagira.git

- Install bundle

    bundle install

- Run test suite

  - First to test your package

    Run rspec tests in +development+ and/or +test+ environments. In
    this case Nagira will use proven to work files included with the
    distribution (in test/data directory).

        RACK_ENV#<development|test> rspec -fd 

  - Test production

        RACK_ENV#production rspec -fd 


- Run application

    bundle exec ./nagira.rb 
    
or

    rackup -p <port>

- Access 
  
Go to URL: http://localhost:4567/status

## Init.d start file 

### Install init.d file

Rake task is provided for installation of /etc/init.d start file. This task will parse provided ERB template (`./config/nagira.init_d.erb`) and configure services to start at boot time. Start file is `/etc/init.d/nagira`. 

This task should be executed as `root` user. To install start file run:

```
rake config:init_d
```

### Configure services

`config:service` task  configures services to run at boot time. 

Note: *As of time of writing (v.0.2) this task only works on Debian or Ubuntu Linux distribution, and fails on any other Linux/UNIX system.*


## See also

* See more on {file:CONFIGURATION.rdoc}

* If you are getting misformed XML errors, please look at
  {file:nagios_objects.rdoc}
