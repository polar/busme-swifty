#!/bin/sh -x
echo "Starting Nginx"
sudo /etc/init.d/nginx start
bundle exec scripts/start_frontend.rb $*
echo "Done"
