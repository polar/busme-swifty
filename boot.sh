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

su - ec2-user <<EOF
sh ./busme-swifty/stop_rogues.sh
sh ./busme-swifty/start_rogues.sh
EOF