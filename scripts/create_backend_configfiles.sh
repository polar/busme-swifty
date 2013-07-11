#!/bin/sh

cd ~/busme-swifty

NAME=$1
MASTER_SLUG=$2
FRONTEND_ADDRESS=$3
HOSTNAME=$4
SERVER_NAME=$5
CLUSTER_ADDRESS=$6
CLUSTER_PORT=$7
BACKEND_ADDRESS=$8
BACKEND_PORT=$9
SSL_CERT=$10
SSL_KEY=$11

if [ "x$SSL_CERT" = "x" ]; then
   SSL_CERT=\\/etc\\/ssl\\/certs\\/busme-us.pem
   SSL_KEY=\\/etc\\/ssl\\/certs\\/busme-us.pem
fi

if [ "x$MASTER_SLUG" = "x" ]; then
    FNAME=ZZ-$NAME
else
    FNAME=AA-$NAME
fi

midir -p backends.d

if [ ! -e /etc/nginx/conf.d/$FNAME.conf ]; then
    sed -e "s/@MASTER_SLUG/$MASTER_SLUG/" rouge-nginx.conf.template |\
    sed -e "s/@FRONTEND_ADDRESS/$FRONTEND_ADDRESS/" |\
    sed -e "s/@HOSTNAME/$HOSTNAME/" | \
    sed -e "s/@SERVER_NAME/$SERVER_NAME/" | \
    sed -e "s/@CLUSTER_ADDRESS/$CLUSTER_ADDRESS/" |\
    sed -e "s/@CLUSTER_PORT/$CLUSTER_PORT/" |\
    sed -e "s/@BACKEND_ADDRESS/$BACKEND_ADDRESS/" |\
    sed -e "s/@BACKEND_PORT/$BACKEND_PORT/" |\
    sed -e "s/@SSL_CERT/$SSL_CERT/" | \
    sed -e "s/@SSL_KEY/$SSL_KEY/" > ~/busme-swifty/backends.d/$FNAME.conf
fi

mkdir -p start.d

if [ ! -e ./start.d/$FNAME.sh ];then
    sed -e "s/@MASTER_SLUG/$MASTER_SLUG/" rouge-start.sh.template |\
    sed -e "s/@FRONTEND_ADDRESS/$FRONTEND_ADDRESS/" |\
    sed -e "s/@HOSTNAME/$HOSTNAME/" | \
    sed -e "s/@SERVER_NAME/$SERVER_NAME/" | \
    sed -e "s/@CLUSTER_ADDRESS/$CLUSTER_ADDRESS/" |\
    sed -e "s/@CLUSTER_PORT/$CLUSTER_PORT/" |\
    sed -e "s/@BACKEND_ADDRESS/$BACKEND_ADDRESS/" |\
    sed -e "s/@BACKEND_PORT/$BACKEND_PORT/" |\
    sed -e "s/@SSL_CERT/$SSL_CERT/" | \
    sed -e "s/@SSL_KEY/$SSL_KEY/" > ~/busme-swifty/start.d/$FNAME.sh
fi

