#!/bin/bash

docker rmi -f test-worker:test

docker build . \
       --no-cache \
       -t test-worker:test
