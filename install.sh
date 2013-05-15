#!/bin/bash

# Assumes git clone into busme-swifty, obviously because this file is here.

cd ~ec2-user/busme-swifty
cp init.sh /etc/init.d/swifty

chmod 0755 /etc/init.d/swifty
ln -s /etc/init.d/swifty /etc/rc.d/rc.0/K20swifty
ln -s /etc/init.d/swifty /etc/rc.d/rc.1/K20swifty
ln -s /etc/init.d/swifty /etc/rc.d/rc.2/S20swifty
ln -s /etc/init.d/swifty /etc/rc.d/rc.3/S20swifty
ln -s /etc/init.d/swifty /etc/rc.d/rc.4/S20swifty
ln -s /etc/init.d/swifty /etc/rc.d/rc.5/S20swifty
ln -s /etc/init.d/swifty /etc/rc.d/rc.6/K20swifty
