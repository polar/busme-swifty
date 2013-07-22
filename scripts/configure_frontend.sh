#!/bin/sh -x
echo $0 $*
cd ~/busme-swifty
bundle update
bundle exec scripts/configure_frontend.rb $*