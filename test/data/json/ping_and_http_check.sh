#!/bin/sh +x
curl -X PUT -H "Content-type: application/json;" \
    -d @ping_and_http.json \
    http://localhost:4567/_status/svaroh/_services
