#!/bin/sh -x
cd ~/busme-swifty
bundle update
bundle exec scripts/configure_frontend.rb $*