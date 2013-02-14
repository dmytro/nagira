# @title Troubleshooting Nagira

## Runtime Configuration

Runtime configuration is available from:

* Nagira logfile (or STDOUT) when ran from command line. 
* Using API endpoint `/_runtime`

### Example output

* STDOUT

````
    $ RACK_ENV=production bundle exec ./nagira.rb
    [2013-02-14 18:26:23 +0900] -- Starting Nagira allication
    [2013-02-14 18:26:23 +0900] -- Using nagios file config: /usr/local/nagios/etc/nagios.cfg
    [2013-02-14 18:26:23 +0900] -- Using nagios file status: /usr/local/nagios/var/status.dat
    [2013-02-14 18:26:23 +0900] -- Using nagios file objects: /usr/local/nagios/var/objects.cache
    [2013-02-14 18:26:23 +0900] -- Using nagios file commands: /usr/local/nagios/var/rw/nagios.cmd
    [2013-02-14 18:26:23 +0900] Starting background parser thread with interval 4.9 sec
    [2013-02-14 18:26:23] INFO  WEBrick 1.3.1
    [2013-02-14 18:26:23] INFO  ruby 1.9.3 (2013-01-15) [x86_64-darwin11.4.2]
    == Sinatra/1.3.2 has taken the stage on 4567 for production with backup from WEBrick
    
````

* API

````
    $ curl http://localhost:4567/_runtime.yaml

    :application: !ruby/class 'Nagira'
    :version: 0.2.1
    :runtime:
        :environment: :production
        :home: /Users/dmytro
        :user: dmytro
        :nagiosFiles:
            - :config: /usr/local/nagios/etc/nagios.cfg
            - :status: /usr/local/nagios/var/status.dat
            - :objects: /usr/local/nagios/var/objects.cache
            - :commands: /usr/local/nagios/var/rw/nagios.cmd
````  
  
