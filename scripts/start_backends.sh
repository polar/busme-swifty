#!/bin/sh
cd ~ec2_user/busme-swifty/start.d
bundle exec ruby scripts/start_backends.rb $*