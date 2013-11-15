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

USER=ec2-user
HOME=~$USER/busme-swifty

echo "$*"

start() {
    [ -e $HOME/scripts/stop_backends.sh ] || exit 5
    [ -e $HOME/scripts/start_backends.sh ] || exit 5
    echo $"Starting Swifty"
    su - $USER <<EOF
    sh $HOME/scripts/stop_backends.sh
    sh $HOME/scripts/start_backends.sh
EOF
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $lockfile
    return $retval
}

stop() {
    [ -e $HOME/scripts/stop_backends.sh ] || exit 5
    echo $"Stopping Swifty"
    su - $USER <<EOF
    sh $HOME/scripts/stop_backends.sh
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
    [ -e $HOME ] || exit 5
    su - $USER <<EOF
    cd $HOME
    git pull
EOF
    cp $HOME/nginx.conf /etc/nginx
}

reinstall() {
    [ -e $HOME ] || exit 5
    sh $HOME/install.sh
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
        reload
        ;;
    reinstall)
        upgrade
        reinstall
        ;;
    *)
        echo $"Usage: $0 {start|stop|reload|status|force-reload|upgrade|restart}"
        exit 2
esac
