#!/bin/sh +x
curl -X PUT -H "Content-type: application/json;" \
    -d @host_check.json \
    http://localhost:4567/_status/svaroh.yaml
