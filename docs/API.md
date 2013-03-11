# @title Nagira API

This document describes specifications of Nagira API: endpoints, HTTP methods and output.

Examples of the curl command and output are given in {file:FEATURES.md} file. 

Output format
======================

Output format is spcified by extension at the end of the HTTP request. It can be 1 of `.xml`, `.json` or `.yaml`.  If output specifier is absent Nagira will use default configured format (see {file:CONFIGURATION.md}.

Top level routes
======================

General information
---------------------------------

API endpoints in General section do not provide Nagios information, they are  used to receive from Nagira information related to Nagira application itself and Nagios instance Nagira talks to. 

### `/` (*root*) endpoint

- Method GET

- Returned attributes
  - `application`
  - `version`
  - `source`
  - `apiUrl`

Provides general inforamtion about Nagira application, no nested routes.

----

### `/_api` endpoint

Prints out available routes on the Nagira aplication. No nested subroutes.

- Method: GET
- Returned data: routes available for each HTTP method: `GET`, `HEAD`, `PUT`

----- 

### `/_runtime`

- Method GET

Print runtime Nagira environment configuration. No nested subroutes.

Available: since Nagira version > 0.2.1


- Returnded data:
  - `application` - name of the application (Nagira)
  - `version` 
  - `runtime`  - Hash with runtime environment of Nagira
    - `environment` - development, test or porduction
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

Nagios inforamtion section describes methods for accessing Nagios objects and status information, as well as updating status information.

### `/_config`

- Method GET

Nagios server configuration information: location of Nagios configuration files, log files, various setting usually found in main Nagios configuration file `nagios.cfg`.

No nested subroutes/endpoints available.

- Returned data: 
  
  Hash with all configuration options of Nagios server. 
  See for example: http://nagios.sourceforge.net/docs/3_0/configmain.html
  All attributes are formatted exactly as they are read from `nagios.cfg` file without any conversions.

-----

## Nagios objects information

### Extensions

`/_objects` and `/_status` family of routes support extensions `_list`, `_state` and `_fulll` and can use of both plural and singular names of resources. Specifications below show where each one of the extensions can or can not  be used.

#### `_list`,`_state` and `_full`

Either `_list`, `_state` oe `_full` keyword can be appended to the HTTP request path at the end to modify responce as:

* `_list` option produces only list of hosts/services
* `_state` - gives short status of host or service
* `_full` - provide where available extended status information

As for example:

* `/_status` - will provide full list of all hosts together with hoststaus information, but 
* `/_status/_list` - provides only list of hosts as an array.

**Note**: `_list` modifier changes output type of the request. `/_status` and `/_object` request can return either Hash or Array, depending on other parts of request (see below, plural vs singular) but `_list` request always returns Array.

#### Plural and singular resources

Nagira API up to version 0.2.1 used Nagios resources as nouns in singular form ('host', 'hostgroup', 'service', 'contact'), same way as they are used by Nagios. In order to support ActiveResource type of requests, use of pluralized resources has been added. 

ActiveResource expects JSON output of search result in the form of Array, but Nagira provides results as Hash. So, in order to be ActiveResource compliant without breaking backward compatibility, following rule is used:

- if HTTP request points to resource in singular form, Nagira outputs Hash
- otherwise it outputs an Array

Where this is available following forms of request are supported:

- /_status/host/<name> - singular (Nagira)
- /_status/hosts/<name> - plural  (ActiveResource)
- /_status/hosts/<id>   - by ID   (ActiveResource)

### `/_objects`

All Nagios object configurations grouped into Hash subtrees by resource type (host, service, contact, command). 

List of all possible objects can be obtained from http://nagios.sourceforge.net/docs/3_0/objectdefinitions.html.

**Note** Only currently configured objects are listed.

- Method GET
- Output data: Hash
- Supports  extention
  - `_list`: yes
  - `_state`: no
  - plural resources: n/a



-----

### `/_status`

- Method GET:
  Get all hosts status, see {Nagira#get_status}

#### `/_status/:hostname`

- Method GET
  Hoststatus for single host, see {Nagira#get\_status\_hostname\_services}


#### `/_status/:hostname/_services`

- Method GET
  - All services for single host. Not including hoststate information.
  - see {Nagira#get\_status\_hostname\_services}
