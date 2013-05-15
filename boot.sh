#!/bin/bash

cd ~ec2-user

cd ./busme-swifty

git pull

chown -R ec2-user:ec2-user .

cp nginx.conf /etc/nginx
/etc/init.d/nginx restart

mkdir -p /var/log/swifty
chown ec2-user:ec2-user /var/log/swifty

su - ec2-user <<EOF
source ~/.busme_creds
cd ./busme-swifty
bundle install

# busme.us
bundle exec ruby rogue.rb --port 3000 &> /var/log/swifty/busme.log &

# sites.busme.us
bundle exec ruby rogue.rb --port 3010 &> /var/log/swifty/sites.log &

# lake-shore-limited.busme.us
bundle exec ruby rogue.rb --port 3020 &> /var/log/swifty/lake-shore-limited.log &

# syracuse-university.busme.us
bundle exec ruby rogue.rb --port 3030 &> /var/log/swifty/syracuse-university.log &

# apis.busme.us is currently hosted on Heroku due to the SSL validation issue.

EOF