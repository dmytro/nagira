## Name

Nagira -- Nagios RESTful API

Version {include:file:version.txt}

[![Build Status](https://travis-ci.org/dmytro/nagira.png)](https://travis-ci.org/dmytro/nagira)

## Description

- Light-weight web services RESTful API for reading and changing status of Nagios objects:
  - host status 
  - service status
- and for read-only access to:
* Nagios objects 
  - hosts
  - services, 
  - contacts, 
  - groups of 
      - hosts
      - services
      - contacts
      - escalations, etc.
* Nagios server configuration
* Nagios runtime environment


## Source Code

Source code available from Github https://github.com/dmytro/nagira

## Installation

See {file:INSTALL.rdoc}

## Usage

1. Run Sinatra application `bundle exec ./nagira.rb`
2. Use HTTP client to get information:

```
   curl http://localhost:4567/objects/contact/list
   
   curl http://localhost:4567/status/list
```

or to send check result to Nagios:

```shell

curl -X PUT -H "Content-type: application/json;" \
    -d @host_check.json http://nagios.example.com:4567/_status/web_server
    

 {
  "status_code":"0",
  "plugin_output" : "ping OK"
 }
 
```    
    
See more in {file:FEATURES.rdoc}

## Documentation

YARD documentation included with the project, run `yardoc` in project root directory. Generated YARD docs are available at http://dmytro.github.com/nagira/doc

## How and why?

### Provide simple and consistent way for information exchange with Nagios

1. Provide read-only access to the object configuration and object states by reading Nagios data files: `status.dat` and `objects.cache`, and 
   * `objects.cache` file keeps information about Nagios configuration (lists of servers, services, groups etc);
   * `status.dat` file is file that stores information about current state of the objects (hosts and services) and Nagios process itself;
   * Nagios configuration information is in `nagios.cfg` file, by reading and parsing this file all other configuration can be obtained. 
1. provide check result submission interface (similar to [Nagios NSCA](http://nagios.sourceforge.net/docs/3_0/addons.html) and for setting/updating Nagios configuration.


If necessary at a later stages this could be implemented using Nagios' NEB interface, but the disadvantage of the NEB API is that it could block Nagios process and introduce latencies in Nagios.

File parsing obviously takes resources for each single parse, however
if application -- Rails, Sinatra or similar -- is able to keep state
of the parser, is not a problem. IF application can keep track of file
parse times and file modification time it is possible to parse file
only if it was changed and infrequently enough.

# Road-map blueprint

When implemented API could provide foundation for development of
well-defined, modular, distributed Nagios monitoring: distributed
Nagios nodes communicating with each other, retrieving status and
submitting check results, distributed, load-balanced, fault tolerant
configuration.

Web GUI (IMHO weakest part of the Nagios) could be completely
de-coupled from Nagios core and is not required to run on the Nagios
core host.

## First stage

Note: *Implemented in version 0.1*

Read-only (GET) routes to access lists of monitored objects and states
of the objects.

There are examples of various Nagios interfaces: [NDOUTILS][ndoutils], [IdoUtils][idoutils], [MK_Livestatus][mk_livestatus]. This is an attempt to do similar things using web services API.

[ndoutils]: http://exchange.nagios.org/directory/Addons/Database-Backends/NDOUtils/details
[idoutils]: http://docs.icinga.org/latest/en/quickstart-idoutils.html
[mk_livestatus]: http://mathias-kettner.de/checkmk_livestatus.html

## Second stage

Note: *Implemented starting from v0.2.*

Implement NCSA passive checks submission functionality using HTTP(S) web service. 

Starting version v0.2 two Nagios external commands implemented `PROCESS_HOST_CHECK_RESULT` and `PROCESS_SERVICE_CHECK_RESULT`. This allows submitting passive check results for hosts and services, and implements accordingly functionality NSCA. 

## Later stages

Use POST/PUT/DELETE HTTP methods to control Nagios - automatically change configuration, control notifications, contacts; in many cases this requires Nagios process restarts/reloads. 

There are 157 external commands in Nagios 3, compared to 2 implemented, so this is still far away... 

## Author

Dmytro Kovalov, dmytro.kovalov@gmail.com

2011, Dec, 26th  - started

## License

MIT, see {file:LICENSE.rdoc}
