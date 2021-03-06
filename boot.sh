#!/bin/bash

# We pull down any configuration files and commands in case they changed.

su - ec2-user <<EOF
    cd ./busme-swifty
    git pull
EOF

cp ~ec2-user/busme-swifty/nginx.conf /etc/nginx
/etc/init.d/nginx restart

# We run as the user.
su - ec2-user <<EOF
    sh ./busme-swifty/scripts/stop_backends.sh
    sh ./busme-swifty/scripts/start_backends.sh
EOF