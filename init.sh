#!/bin/sh
#
# swifty - this script starts and stops the swifty rogue daemons
#
# chkconfig:   - 85 15
# description:  Swifty is a set of rogue runners for Busme!
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
    [ -e ~ec2-user/busme-swifty/stop_rogues.sh ] || exit 5
    [ -e ~ec2-user/busme-swifty/start_rogues.sh ] || exit 5
    echo $"Starting Swifty"
    su - ec2-user <<EOF
    sh ~ec2-user/busme-swifty/stop_rogues.sh
    sh ~ec2-user/busme-swifty/start_rogues.sh
EOF
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}

stop() {
    [ -e ~ec2-user/busme-swifty/stop_rogues.sh ] || exit 5
    echo $"Stopping Swifty"
    su - ec2-user <<EOF
    sh ~ec2-user/busme-swifty/stop_rogues.sh
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

rh_status() {
    return [ -e ~ec2-user/busme-swifty ]
}

rh_status_q() {
    rh_status >/dev/null 2>&1
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
        rh_status_q && exit 0
        start
        ;;
    stop)
        rh_status_q || exit 0
        stop
        ;;
    restart)
        restart
        ;;
    force-reload|upgrade) 
        rh_status_q || exit 7
        upgrade
        ;;
    reload)
        rh_status_q || exit 7
        $1
        ;;
    reinstall)
        rh_status_q || exit 7
        upgrade
        reinstall
        ;;
    status|status_q)
        rh_$1
        ;;
    condrestart|try-restart)
        rh_status_q || exit 7
        restart
	    ;;
    *)
        echo $"Usage: $0 {start|stop|reload|status|force-reload|upgrade|restart}"
        exit 2
esac
