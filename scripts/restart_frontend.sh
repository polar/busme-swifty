#!/bin/sh -x
echo "Restarting Nginx"
sudo /etc/init.d/nginx restart
bundle exec scripts/restart_frontend.rb $*
echo "Done"