#!/bin/bash

cd ~ec2-user

cd ./busme-swifty

git pull

chown -R ec2-user:ec2-user .

cp nginx.conf /etc/nginx
/etc/init.d/nginx restart

mkdir -p /var/log/swifty
chown ec2-user:ec2-user /var/log/swifty

mkdir -p /var/run/swifty
chown ec2-user:ec2-user /var/run/swifty
cd /var/run/swifty
for i in *.pid; do
    kill -HUP `cat $i` >& /dev/null
done >& /dev/null
sleep 5
for i in *.pid; do
    kill -KILL `cat $i` >& /dev/null
    rm -f $i
done >& /dev/null

su - ec2-user <<EOF
sh ./busme-swifty/start_rogues.sh
EOF