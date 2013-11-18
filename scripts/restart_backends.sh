#!/bin/sh  -x
cd ~/busme-swifty
bundle exec ruby scripts/stop_backends.rb $*
bundle exec ruby scripts/start_backends.rb $*