#!/bin/sh -x
echo $0 $*
cd ~/busme-swifty
bundle exec scripts/configure_frontend_backends.rb $*