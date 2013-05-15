#!/bin/bash
env

source ~/.busme_creds
cd ~/busme-swifty
bundle install

# busme.us
bundle exec ruby rogue.rb --cluster-port 3000 --backend-port 4000 >& /var/log/swifty/busme.log &
PID=$!
echo The Process Id is $! and $PID
echo $PID
echo $PID > /var/run/swifty/busme.pid

# sites.busme.us
bundle exec ruby rogue.rb --master-slug sites --cluster-port 3010 --backend-port 4010 >& /var/log/swifty/sites.log &
PID=$!
echo $PID
echo $PID > /var/run/swifty/sites.pid

# lake-shore-limited.busme.us
bundle exec ruby rogue.rb --master-slug lake-shore-limited --cluster-port 3020 --backend-port 4020 >& /var/log/swifty/lake-shore-limited.log &
PID=$!
echo $PID
echo $PID > /var/run/swifty/lake-shore-limited.pid

# syracuse-university.busme.us
bundle exec ruby rogue.rb --master-slug syracuse-university --cluster-port 3030 --backend-port 4030 >& /var/log/swifty/syracuse-university.log &
PID=$!
echo $PID
echo $PID > /var/run/swifty/syracuse-university.pid

# apis.busme.us is currently hosted on Heroku due to the SSL validation issue.
