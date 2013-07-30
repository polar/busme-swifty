#!/bin/sh -x
cd ~/busme-swifty
git stash
git pull
bundle update
sudo cp nginx.conf /etc/nginx
sudo /etc/init.d/nginx restart
exit 0