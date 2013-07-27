#!/bin/sh -x
cd ~/busme-swifty
git stash
git pull
bundle update
sudo cp nginx.conf /etc/nginx
exit 0