# @title API Namespacing Guideline

This is an attempt to standardize on namespacing API routes, for the consistency sake. The rules set here can be changed if there is a god reason for it, otherwise please follow these rules.

# Top level routes #

Top level routes limited to following ones, no new routes will be added.

* /_config
* /_objects
* /_status
* /_api
* /_runtime
* /

## Implemented

"PUT":

- /_status
- /_status/:host_name
- /_status/:host_name/_services
- /_status/:host_name/_services/:service_description
- /_status/:host_name/_services/:service_description/_return_code/:return_code/_plugin_output/:plugin_output


Deprecated to be removed:
- /_host_status/:host_name


## Future additions

Host and service properties (notifications, checks enabled/disabled) are nested under the host and service endpoints correspondingly.

### Host

- PUT /_status/:host_name/_active_checks
- PUT /_status/:host_name/_passive_checks
- PUT /_status/:host_name/_notifications

### Service

- PUT /_status/:host_name/_services/:service_description/_notifications/

    - Params
          - notifications_enabled
          - notification_options

- PUT /_status/:host_name/_services/:service_description/_active_checks
- PUT /_status/:host_name/_services/:service_description/_passive_checks
- PUT /_status/:host_name/_services/:service_description/_flap_detection
