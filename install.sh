#!/bin/bash

# Assumes git clone into busme-swifty, obviously because this file is here.

cd ~ec2-user/busme-swifty
cp init.sh /etc/init.d/swifty

chmod 0755 /etc/init.d/swifty
update-rc.d swifty defaults
