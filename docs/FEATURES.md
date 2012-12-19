
# FEATURES

* HTTP GET request to retrive Nagios server or objects configuration, and for host or service status 

* Multiple output formats: add format extension at the end of the
  route (`.xml`, `.json`, `.yaml`)

* Use named routes (`hostname`, `service_name`), not ID's in RESTful request

* Full or short host or service state information (for short summary add `/_state` at the end of the route)

* Lists of objects (hosts, services, configured objects) where applicable: add `/list` at the end of the route

## Routes for configured objects in the system

Namespace for object configuration starts from "/_objects". Route may
be appended by `/_list` to get short list of objects or object classes.

All routes can be followed by format specifier: `.xml`, `.yaml`, `.json`. When format specifier is omitted, default format output is used (configurable).

Following routes are implemented (all `GET`):

* `/_objects` - all configured and parsed objects, groupped by class.

* `/_objects/_list` - list all configured and parsed object types

* `/_objects/object-class` - full configuration of all objects in the given class. `object_class` is one of: _host_, _hostgroup_, _servicegroup_, etc. Any of the acceptable configuration options for Nagios. Note, object of the specific class must exist in `objects.cache` file, or it will not appear on the list.

* `/_objects/object-class/_list` - short list of all names of configured objects

* `/_objects/object-class/object-name` - full configuration of the object.

## Routes to get service status information

Every route can optionally end with `/_list` or `/_state` and format specifier `\.(xml|json|yaml)`

* `/list` option produces only list of hosts/services
* `/state` - gives short status of host or service
* if none are provided, then will print out full parsed hash 


### Hosts
* `/_status` - full list of all hosts with service(s) information
* `/_status.xml`
* `/_status/_list` - list of hosts
* `/_status/_list.xml`

### Services

* `/_status/_hostname_`
* `/_status/_hostname_/services(/(_list|_state).FORMAT_EXTENSION?)?`
* `/_status/_hostname_/services/_service name_`

## Examples

### Application summary 

```
curl http://localhost:4567/
{"application":"Nagira",
 "version":"0.2.0",
 "source":"http://dmytro.github.com/nagira/",
 "apiUrl":"http://localhost:4567/_api"}
```

### See API information

This command will print list of all implemented API endpoints. Note: *this list is shortened for readability*.

```
$ curl http://localhost:4567/_api.xml
<?xml version="1.0" encoding="UTF-8"?>
<hash>
  <GET type="array">
    <GET>/_config</GET>
    <GET>/_objects</GET>
    <GET>/_objects/:type</GET>
    [...]
  </GET>
  <HEAD type="array">
    <HEAD>/_config</HEAD>
    <HEAD>/_objects</HEAD>
    <HEAD>/_objects/:type</HEAD>
    [...]
  </HEAD>
  <PUT type="array">
    <PUT>/_status</PUT>
    [...]
  </PUT>
</hash>
```

### Nagios server configuration

This will retrive full configuration of Nagios process. 

*Same as above this is shortened list.*

```
$ curl http://localhost:4567/_config.xml
<?xml version="1.0" encoding="UTF-8"?>
<hash>
  <log-file>/var/log/nagios3/nagios.log</log-file>
  <cfg-file type="array">
    <cfg-file>/etc/nagios3/commands.cfg</cfg-file>
  </cfg-file>
  <cfg-dir type="array">
    <cfg-dir>/etc/nagios-plugins/config</cfg-dir>
    <cfg-dir>/etc/nagios3/conf.d</cfg-dir>
  </cfg-dir>
  [...]
```  

### Status information: hosts and services

        curl http://localhost:4567/_status

        curl http://localhost:4567/_status/viy/_state

        curl http://localhost:4567/_status/viy/_services/_list
        curl http://localhost:4567/_status/viy/_services/list.json

        curl http://localhost:4567/_status/viy/_services/state
        curl http://localhost:4567/_status/viy/_services/state.yaml

        curl http://localhost:4567/_status/viy/_services/SSH
        curl http://localhost:4567/_status/viy/_services/SSH/state.yaml

### Objects configuration

        curl   http://localhost:4567/_objects/command
        curl   http://localhost:4567/_objects/command/_list
        curl   http://localhost:4567/_objects/command.json

        curl   http://localhost:4567/_objects/command/traffic-average
        curl   http://localhost:4567/_objects/command/traffic_average.yaml

        curl   http://localhost:4567/_objects/contact
        curl   http://localhost:4567/_objects/contact/_list
        curl   http://localhost:4567/_objects/contact/_list.yaml

        curl   http://localhost:4567/_objects/host/_list.yaml
        curl   http://localhost:4567/_objects/host/viy


### More examples

Some examples are included with the distribution in the `./test/data/json` directory. This directory have examples of JSON files for HTTP PUT's and sample `curl` script to be used with JSON files. See also `README.txt` file in this directory.
