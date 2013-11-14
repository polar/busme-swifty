#!/bin/bash

NAME=${1:-busme-swifty}
USER=${2:-ec2-user}

# Assumes git clone into busme-swifty, obviously because this file is here.

cd ~$USER
cd "$NAME"

cp ./bashrc.sh ~ec2-user/.bashrc

cd ./src
make
cd ..
chown root:root scripts/nginx_cmd
chmod 4755 scripts/nginx_cmd

chmod +x ./scripts/*

cp ./nginx.conf /etc/nginx

mkdir -p /var/log/swifty
chown ${USER}:${USER} /var/log/swifty

mkdir -p /var/run/swifty
chown ${USER}:${USER} /var/run/swifty

echo "INSTALL COMPLETE"