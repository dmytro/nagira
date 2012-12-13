#!/bin/sh +x
curl -X PUT -H "Content-type: application/json;" \
    -d @ping.json \
    http://localhost:4567/_status/svaroh/_services
