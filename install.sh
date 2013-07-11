#!/bin/bash

# Assumes git clone into busme-swifty, obviously because this file is here.

cd ~ec2-user/busme-swifty
bundle install

cd src
make
cd ~ec2-user/busme-swifty
chown root:root scripts/nginx_cmd
chmod 4755 scripts/nginx_cmd

chmod +x scripts/*

cp swifty.sh /etc/init.d/swifty
cp nginx.conf /etc/nginx

chmod 0755 /etc/init.d/swifty
ln -s /etc/init.d/swifty /etc/rc.d/rc0.d/K20swifty   >& /dev/null
ln -s /etc/init.d/swifty /etc/rc.d/rc1.d/K20swifty   >& /dev/null
ln -s /etc/init.d/swifty /etc/rc.d/rc2.d/S20swifty   >& /dev/null
ln -s /etc/init.d/swifty /etc/rc.d/rc3.d/S20swifty   >& /dev/null
ln -s /etc/init.d/swifty /etc/rc.d/rc4.d/S20swifty   >& /dev/null
ln -s /etc/init.d/swifty /etc/rc.d/rc5.d/S20swifty   >& /dev/null
ln -s /etc/init.d/swifty /etc/rc.d/rc6.d/K20swifty   >& /dev/null

mkdir -p /var/log/swifty
chown ec2-user:ec2-user /var/log/swifty

mkdir -p /var/run/swifty
chown ec2-user:ec2-user /var/run/swifty