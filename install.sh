#!/bin/bash

# Assumes git clone into busme-swifty, obviously because this file is here.

cd ~ec2-user/busme-swifty
cp init.sh /etc/init.d/swifty

chmod 0755 /etc/init.d/swifty
ln -s /etc/init.d/swifty /etc/rc.d/rc0.d/K20swifty   >& /dev/null
ln -s /etc/init.d/swifty /etc/rc.d/rc1.d/K20swifty   >& /dev/null
ln -s /etc/init.d/swifty /etc/rc.d/rc2.d/S20swifty   >& /dev/null
ln -s /etc/init.d/swifty /etc/rc.d/rc3.d/S20swifty   >& /dev/null
ln -s /etc/init.d/swifty /etc/rc.d/rc4.d/S20swifty   >& /dev/null
ln -s /etc/init.d/swifty /etc/rc.d/rc5.d/S20swifty   >& /dev/null
ln -s /etc/init.d/swifty /etc/rc.d/rc6.d/K20swifty   >& /dev/null
