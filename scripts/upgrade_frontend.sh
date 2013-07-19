#!/bin/sh -x
cd ~/busme-swifty
git pull
bundle update
sudo cp nginx.conf /etc/nginx
exit 0