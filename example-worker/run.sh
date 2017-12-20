#!/bin/bash

docker stop test-worker
docker rm test-worker

docker run \
       --detach \
       --name="test-worker" \
       --env BUILDMASTER=example.com \
       --env BUILDMASTER_PORT=9990 \
       --env WORKERNAME=test-worker \
       --env WORKERPASS=change_me \
       test-worker:test
