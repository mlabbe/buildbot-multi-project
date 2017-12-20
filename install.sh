#!/bin/sh

SYSPATH="/etc/systemd/system"
SERVICE="buildbot"

cp $SERVICE.service $SYSPATH

systemctl daemon-reload
systemctl enable $SYSPATH/$SERVICE.service
systemctl start $SERVICE
