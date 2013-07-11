#!/bin/sh
cd ~ec2_user/busme-swifty/start.d
for i in *.sh
do
    sh -x $i
end