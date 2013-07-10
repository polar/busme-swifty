#!/bin/sh

MASTER_SLUG=$1
HOSTNAME=$2
CLUSTER_PORT=$3

cd /var/run/swifty

if [ -e  $MASTER_SLUG.$HOSTNAME-$CLUSTER_PORT.pid ]; then
    kill -HUP `cat $MASTER_SLUG.$HOSTNAME-$CLUSTER_PORT.pid`
    sleep 5
fi

if [ -e  $MASTER_SLUG.$HOSTNAME-$CLUSTER_PORT.pid ]; then
    kill -KILL `cat $MASTER_SLUG.$HOSTNAME-$CLUSTER_PORT.pid`
fi
