#!/bin/sh -x
scripts/nginx_cmd stop
bundle exec ruby scripts/stop_frontend.rb $*