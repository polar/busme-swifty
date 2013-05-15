#!/bin/bash

cd /var/run/swifty

echo "Stopping Rogues"
for i in *.pid; do
    kill -HUP `cat $i` >& /dev/null
done >& /dev/null

sleep 5

for i in *.pid; do
    kill -KILL `cat $i` >& /dev/null
    rm -f $i
done >& /dev/null
echo "Done Stopping Rogues"
