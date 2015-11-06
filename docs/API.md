# @title Nagira API

This document describes specifications of Nagira API: endpoints, HTTP methods and output.

Examples of the curl command and output are given in {file:FEATURES.md} file.

Supported Output formats
======================

Output format is specified by extension at the end of the HTTP request. It can be 1 of `.xml`, `.json` or `.yaml`.  If output specifier is absent Nagira will use default configured format (see {file:CONFIGURATION.md}.

Default responses
======================

## Success

- Status: 200
- Data: either Hash or Array (one of the supported types)

## Failure

For not existing routes, object not found or object not configured in Nagios, 404 is returned. At the momemnt it is impossible to distinquish between non-existing routes and non-existing object(s).


Top level routes
======================

General information
---------------------------------

API endpoints in General section do not provide Nagios information, they are  used to receive from Nagira information related to Nagira application itself and Nagios instance Nagira talks to.

### GET `/` (*root*)

- Returned attributes
  - `application`
  - `version`
  - `source`
  - `apiUrl`

Provides general information about Nagira application, no nested routes.

----

### GET `/_api`

Prints out available routes on the Nagira application. No nested sub-routes.

- Returned data: routes available for each HTTP method: `GET`, `HEAD`, `PUT`

-----

### GET `/_runtime`

Print runtime Nagira environment configuration. No nested sub-routes.

Available: since Nagira version > 0.2.1


- Returned data:
  - `application` - name of the application (Nagira)
  - `version`
  - `runtime`  - Hash with runtime environment of Nagira
    - `environment` - development, test or production
    - `home` - home directory of the UNIX user running Nagira application (for example: `nagios`)
    - `user` - UNIX user running Nagira application (for example: `nagios`)
    - `nagiosFiles` - PATH's to Nagios configuration files parsed by Nagira
      - `config`  - nagios.cfg
      - `status`  - status.dat
      - `objects` - objects.cache
      - `commands` - remote command file (pipe)

-----

Nagios server information
---------------------------------

Nagios information section describes methods for accessing Nagios objects and status information, as well as updating status information.

### GET `/_config`

Nagios server configuration information: location of Nagios configuration files, log files, various setting usually found in main Nagios configuration file `nagios.cfg`.

No nested sub routes/endpoints available.

- Returned data:

  Hash with all configuration options of Nagios server.
  See for example: http://nagios.sourceforge.net/docs/3_0/configmain.html
  All attributes are formatted exactly as they are read from `nagios.cfg` file without any conversions.

-----


# API Extensions #

`/_objects` and `/_status` family of routes support extensions `_list`, `_state` and `_full` and can use of both plural and singular names of resources. Specifications below show where each one of the extensions can or can not  be used.

## `_list`,`_state` and `_full` ##

Either `_list`, `_state` or `_full` keyword can be appended to the HTTP request path at the end to modify response as:

* `_list` option produces only list of hosts/services
* `_state` - gives short status of host or service
* `_full` - provide where available extended status information

For example:

* `/_status` - will provide full list of all hosts together with host-status information, but
* `/_status/_list` - provides only list of hosts as an array.

**Note**: `_list` modifier changes output type of the request. `/_status` and `/_object` request can return either Hash or Array, depending on other parts of request (see below, plural vs singular) but `_list` request always returns Array.

## Plural and singular resources ##

Nagira API up to version 0.2.1 used Nagios resources as nouns in singular form ('host', 'hostgroup', 'service', 'contact'), same way as they are used by Nagios. In order to support ActiveResource type of requests, use of pluralized resources has been added.

ActiveResource expects JSON output of search result in the form of Array, but Nagira provides results as Hash. So, in order to be ActiveResource compliant without breaking backward compatibility, following rule is used:

- if HTTP request points to resource in singular form, Nagira outputs Hash
- otherwise it outputs an Array

Where this is available following forms of request are supported:

- /_status/host/[name] - singular (Nagira/Nagios)
- /_status/hosts/[name] - plural  (ActiveResource)
- /_status/hosts/[id]   - by ID   (ActiveResource)

--------------------------------------------

# Read Nagios objects configuration #

## GET `/_objects` ##

All Nagios object configurations grouped into Hash subtrees by resource type (host, service, contact, command).

List of all possible objects can be obtained from http://nagios.sourceforge.net/docs/3_0/objectdefinitions.html.

**Note** Only currently configured objects are listed.

- Method GET
- Output data: Hash
- Supports  extension
      - `_list`: yes
      - `_state`: no
      - plural resources: n/a


## GET /_objects/:type ##

Read object type configuration. Object types are supported by Nagios.

- Method GET
- Parameter(s): object type, one of ( timeperiod, command, contactgroup, hostgroup, contact, host, service)
- Output data: Hash
- Supports  extension
    - `_list`: yes
    - plural resources: yes
- Object types

## GET /_objects/:type/:name ##

Read configuration of one object.

- Method GET
- Parameter(s):
    - object type, (see  /_objects/:type)
    - object name

- Example:

    curl localhost:4567/_objects/hostgroup/all

-----

# Read host and services status #

## Host status and host services status ##

### GET `/_status` ###

  Get all hosts status, see {Nagira#get_status}

### Subroutes

#### GET `/_status/:hostname` ####

Read hoststatus for single host, see {Nagira#get\_status\_hostname\_services}


#### GET `/_status/:hostname/_services` ####

- Read all services for single host. Not including host state information.
    - see {Nagira#get\_status\_hostname\_services}


#### GET /_status/:hostname/_services/:service_name

Read single services for single host. Not including host state information.

### Comments

Subrotes _hostcomments and \_servicecomments return comment for the host or service.

#### GET /_status/:hostname/_servicecomments

- Data: Hash

        curl -s localhost:4567/_status/archive/_servicecomments | jsonlint
        {
          "Disk space": [
            {
              "host_name": "archive",
              "service_description": "Disk space",
              "entry_type": "4",
              "comment_id": "38",
              "source": "0",
              "persistent": "0",
              "entry_time": "1373457035",
              "expires": "0",
              "expire_time": "0",
              "author": "dmytro",
              "comment_data": "Need to verify what to delete."
            }
          ]
        }

#### GET /_status/:hostname/_hostcomments

- Data: Array

        $ curl -s localhost:4567/_status/archive/_hostcomments
        [
          {
            "entry_type": "1",
            "comment_id": "40",
            "source": "1",
            "persistent": "1",
            "entry_time": "1375778132",
            "expires": "0",
            "expire_time": "0",
            "author": "dmytro",
            "comment_data": "Testing Host Comment --dk"
          }
        ]


--------------------------------------------
# Read Servicegroup status

### GET /_status/_servicegroup/:servicegroup  ###

- Services information for single servicegroup.
- Output: Hash
- Params: :servicegroup - name of the service group
- Output data format:

```
    { "<hostname>":
        "<servicename>" :
          { "key" : "value", ...},
          ...

```

- Example (YAML)

```
$ curl localhost:4567/_status/_servicegroup/ping.yaml
---
archive:
  PING:
    host_name: archive
    service_description: PING
    modified_attributes: '0'
    check_command: check_ping!100.0,20%!500.0,60%
      ...

```

### Extensions

#### _list

- Only show list of hosts and services
- Example (JSON)

```
$ curl localhost:4567/_status/_servicegroup/ping/_list
{"archive":["PING"],
    "kurobka":["PING","SSH"],
      "airport":["PING"]
}

```

#### _state

- Short status information
- Including: hostname, service description (AKA name), and current
  status
- Example (YAML)

```
      $ curl localhost:4567/_status/_servicegroup/ping/_state.yaml
      ---
      archive:
        PING:
          host_name: archive
          service_description: PING
          current_state: '2'
      kurobka:
        PING:
          host_name: kurobka
          service_description: PING
          current_state: '2'
        SSH:
          host_name: kurobka
          service_description: SSH
          current_state: '2'
      airport:
        PING: {}

```

# Read hostgroup status #

### GET /_status/_hostgroup/:hostgroup ###

- Host and services information for a hostgroup
- Output: Hash
- Params :hostgroup - hostgroup name
  - Data format:

```
    { "<hostname>":
        "hoststatus" :
          { "key" : "value", ...},
        "servicestatus" :
        {
        "<servicename>" :
          { "key" : "value", ...},
```

- Example

```
        "gateway": {
           "hoststatus": {
             "host_name": "gateway",
             "modified_attributes": "0",
             "check_command": "check-host-alive",
             "notification_period": "_24x7",
             },
           "servicestatus": {
             "PING": {
               "host_name": "gateway",
               "service_description": "PING",
               "modified_attributes": "0",
               "check_command": "check_ping!100.0,20%!500.0,60%",
               "check_period": "_24x7",

```

### Subroutes

####  GET /_status/_hostgroup/:hostgroup/_service ####


- Output: Hash
- Services information for a hostgroup
- Params :hostgroup - hostgroup name
- Data format: `{ "hostname": { "service_name": { "key" : "value", ...}, ... }, ...}`
- Example:

```
         {
           "gateway": {
             "PING": {
               "host_name": "gateway",
               "service_description": "PING",
               "modified_attributes": "0",
               "check_command": "check_ping!100.0,20%!500.0,60%",
               "check_period": "_24x7",
               "notification_period": "_24x7",
               "check_interval": "1.000000",
               "retry_interval": "1.000000",

```

####  GET /_status/_hostgroup/:hostgroup/_host ####

- Output: Hash
- Host status information for a hostgroup
- Params :hostgroup - hostgroup name
- Data format: `{ "hostname": { "key" : "value", ...}, ... }`
- Example:

```
         {
         "gateway": {
           "host_name": "gateway",
           "modified_attributes": "0",
           "check_command": "check-host-alive",
           "notification_period": "_24x7",
           "check_interval": "5.000000",
           "retry_interval": "1.000000",
           "has_been_checked": "1",

```
--------------------------------------------

<!--  LocalWords:  xml yaml Nagios apiUrl nagios ActiveResource timeperiod contactgroup hoststatus servicestatus servicename
 -->
