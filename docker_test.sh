#!/bin/bash

docker build --tag demo1 .
docker run -ti demo1 bash -c 'cd /tmp/lib && ruby ps_server.rb'
