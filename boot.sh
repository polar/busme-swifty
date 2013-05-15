#!/bin/bash

# We pull down any configuration files and commands in case they changed.

su - ec2-user <<EOF
    cd ./busme-swifty
    git pull
EOF

cp ~ec2-user/busme-swifty/nginx.conf /etc/nginx
/etc/init.d/nginx restart

mkdir -p /var/log/swifty
chown ec2-user:ec2-user /var/log/swifty

mkdir -p /var/run/swifty
chown ec2-user:ec2-user /var/run/swifty

# We run as the user.
su - ec2-user <<EOF
    sh ./busme-swifty/stop_rogues.sh
    sh ./busme-swifty/start_rogues.sh
EOF