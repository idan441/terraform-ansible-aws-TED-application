#!/bin/bash

#Make an E2E test for ted-search. 
#Based on curling the website host on the local-host. (http://localhost:8080)
if [ $(curl -o -I -L -s -w "%{http_code}" http://localhost:8080) -eq 200 ] ; then
    echo "E2E test passed. "
    exit 0
else
    echo "E2E test failed. "
    exit 1
fi

