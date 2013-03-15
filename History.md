### v.0.2.5

* Fri Mar 15 2013 -- Dmytro Kovalov
  - Environment variables support and defaults file:
    - `NAGIRA_TTL`
    - `NAGIRA_BG_PARSING`
    - `NAGIRA_PORT` - see Sinatra `set :port`
    - `NAGIRA_BIND` - see Sinatra `set :bind`
  - Packaged as gem
    - nagira and nagira-setup binaries
    - cleaner init.d script, support for Debian and RedHat
    - defaults file in `/etc/sysconfig` or `/etc/default`
    - tasks to check configuration by user
  - Add partial ActiveSupport routes
    - `/_objects/host` works as well as `/_objects/hosts`
    - selection objects by ID is TODO
* Feb 19, 2013 -- Dmytro Kovalov    
  - Background parser. 
  
      To avoid delays on HTTP request from user. All data are parsed in separate thread.
    - configurable TTL for background parsing
    - can be disabled
  - Start-up section for the Nagira app. 

      All Nagios files are validated at start-up, rather than on first HTTP request. 

      If there are permission problem or file don't exist error is reported to user.
* Feb 9, 2013    
  - Merge all custom changes to `ruby-nagios` into upstream, use `ruby-nagios` as gem, not git sub-module
  - `nagios.cfg` file selection is in `ruby-nagios` now. 

      Look for config in `/etc/nagios*/` and `/usr/local/nagios/etc/`. Can be overridden by `NAGIOS_CFG_FILE` environment.
  
### v.0.2.1 

* Wed Dec 19 2012 - Dmytro Kovalov
  - fix for DOS formatted and spaces in config ; better error reporting for spec. fixes #8
  - Switch to markdown in documentation: README, CONFIGURAION etc.
  - Configuration documentation. Examples of usage for JSON: example files and scripts.
  - Nagira::INSTALL configuration constant. Use Nagira::INSTALL for init.d creation.
  - ERB  template for /etc/init./d file
  - Fixes for YARD formatting
  - Use Travis CI for Nagira testing
* Thu Oct  4 19:45:00 JST 2012 

###  v.0.2.0

  - lot of bug fixes
  - API: first working PUT API for process host status and process service status external commands
* 2012-09-28 Dmytro Kovalov - v. 0.1.5
  - many changes for testing files nagios.cfg, objects, status. Tested to work both in dev/test and production environments. 
  - more documentation
  - API: additional modifier for output: `_full`. By default now `/_status` returns Hash with hoststatus only. Use ../_full to get both hoststatus and sevicestatus.

### v. 0.1.4  

* 2012-09-26 Dmytro Kovalov - 
  - added support for JSON-P parameters (?callback=<nam>)
  - change API to have all keywords underscored, to avoid clashes with object names (`/_status`, `_objects`, `/_status/_list` etc).

### v. 0.1.3  

* 2012-06-8 Dmytro Kovalov 
  - specs for /config, /status, /objects - simple page loads and data
    checks;
  - /api route;
  - bugfixes;
  - YARD documentation;

### v. 0.1.2  

* 2012-06-2 Dmytro Kovalov 
  - spec for configuration files 
  - spec for basic responses from Sinatra (`GET /objects`, `GET /status`)
  - CONFIGURATION.rdoc
  - configuration cleanup
* 2012-05-22 Dmytro Kovalov
  - start using Gemfile 
  - INSTALL.rdoc - simple description of installation procedure
* 2012-01-12 Dmytro Kovalov
  - History.rdoc and version.txt files
  - Routes for objects configuration GET's
  - FEATURES.rdoc
  - YARD documentation 
* 2012-01-02 Dmytro Kovalov
  - First Sinatra application to return service state information
* 2011-12-25 @dmytro
  - Started Github project

