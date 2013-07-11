#!/bin/sh
#
# swifty - this script starts and stops the swifty rogue daemons
#
# chkconfig:   - 85 15
# description:  Swifty is a set of backends for Busme!
# processname: swifty
# pidfile:     /var/run/swifty

# Source function library.
. /etc/rc.d/init.d/functions

# Source networking configuration.
. /etc/sysconfig/network

# Check that networking is up.
[ "$NETWORKING" = "no" ] && exit 0

lockfile=/var/lock/subsys/swifty

echo "$*"

start() {
    [ -e ~ec2-user/busme-swifty/scripts/stop_backends.sh ] || exit 5
    [ -e ~ec2-user/busme-swifty/scripts/start_backends.sh ] || exit 5
    echo $"Starting Swifty"
    su - ec2-user <<EOF
    sh ~ec2-user/busme-swifty/scripts/stop_backends.sh
    sh ~ec2-user/busme-swifty/scripts/start_backends.sh
EOF
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}

stop() {
    [ -e ~ec2-user/busme-swifty/scripts/stop_backends.sh ] || exit 5
    echo $"Stopping Swifty"
    su - ec2-user <<EOF
    sh ~ec2-user/busme-swifty/scripts/stop_backends.sh
EOF
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $lockfile
    return $retval
}

restart() {
    start
}

reload() {
    echo "No reload"
}

# Upgrade with with no downtime. Must physically restart.
upgrade() {
    [ -e ~ec2-user/busme-swifty ] || exit 5
    su - ec2-user <<EOF
    cd busme-swifty
    git pull
EOF
    cp ~ec2-user/busme-swifty/nginx.conf /etc/nginx
}

reinstall() {
    [ -e ~ec2-user/busme-swifty ] || exit 5
    sh ~ec2-user/busme-swifty/install.sh
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    restart)
        restart
        ;;
    force-reload|upgrade)
        upgrade
        ;;
    reload)
        relload
        ;;
    reinstall)
        upgrade
        reinstall
        ;;
    *)
        echo $"Usage: $0 {start|stop|reload|status|force-reload|upgrade|restart}"
        exit 2
esac
