#!/bin/sh -x
echo $0 $*
cd ~/busme-swifty
bundle exec scripts/configure_backend.rb $*