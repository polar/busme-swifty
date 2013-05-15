Busme-Swifty
============

Notes as of May 15, 2013

Runs on Amazon EC2 Only

Prerequisites.
--------------

Install RVM for Ruby 1.9.3 and do it as ec2-user.

  cd ~
  \curl -L https://get.rvm.io | bash -s -- --version 1.9.3

Install Nginx as root.

  yum install nginx

Install busme-swifty
--------------------

User must be "ec2-user". Since we don't have ssh creds install with the read-only git url.

    cd ~
    git clone   git://github.com/polar/busme-swifty.git
    cd busme-swifty
    sh install.sh   # installs init.sh into /etc/init.d/swifty and copies nginx.conf to /etc/nginx/

Install ".busme_creds" with the credentials for running the system.

    MONGOLAB_URI
    SWIFTIPLY_KEY

Add to ~/.bashrc

    source ~/.busme_creds

Snapshot
--------

At this point, it is probably prudent to snapshot the EC2 instance for further deployments.

Commands
--------

You may do these as root. They will suid down to ec2-user.

Start Rogues

    /etc/init.d/swifty start

Stop Rogues

    /etc/init.d/swifty stop

Restart Rogues

    /etc/init.d/swifty restart

Upgrade

    /etc/init.d/swifty upgrade

    This directive only does the git pull. You have to manually restart swifty and nginx
    in the event of an update to nginx.conf.

Reinstall

    /etc/init.d/swifty reinstall

    This directive does the git pull and runs the install.sh script.
    You have to separately restart swifty and nginx in the event of an update to nginx.conf.

Author
------

Dr. Polar Humenn, Adiron, LLC, (C) 2013 All Rights Reserved.