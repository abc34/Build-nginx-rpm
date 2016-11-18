#!/bin/bash

CENTVER="7"
NGINX="nginx-1.11.6"

echo "Stopping rockstor service ..."
service rockstor stop

echo "Update ..."
rpm -Uvh --force ./$NGINX-1.el$CENTVER.ngx.x86_64.rpm

echo "Starting rockstor service ..."
service rockstor start

