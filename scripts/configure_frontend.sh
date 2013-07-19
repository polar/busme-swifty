#!/bin/sh
cd ~/busme-swifty
bundle update
bundle exec scripts/configure_frontend.rb $*