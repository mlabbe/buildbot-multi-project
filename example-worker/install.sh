#!/bin/sh

# Install the worker with systemd

WORKER_NAME="buildbot-example-worker"

SYSPATH="/etc/systemd/system"

cp $WORKER_NAME.service $SYSPATH
systemctl enable $SYSPATH/$WORKER_NAME.service
