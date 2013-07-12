#!/bin/sh

echo $*

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


mkdir -p ./backends.d

echo "Creating ./backends.d/$NAME.conf"

if [ "x$MASTER_SLUG" = "x" ]; then
    sed -e "s/@MASTER_SLUG/$MASTER_SLUG/g" base-backend-nginx.conf.template |\
    sed -e "s/@NAME/$NAME/g" |\
    sed -e "s/@FRONTEND_ADDRESS/$FRONTEND_ADDRESS/g" |\
    sed -e "s/@HOSTNAME/$HOSTNAME/g" | \
    sed -e "s/@SERVER_NAME/$SERVER_NAME/g" | \
    sed -e "s/@CLUSTER_ADDRESS/$CLUSTER_ADDRESS/g" |\
    sed -e "s/@CLUSTER_PORT/$CLUSTER_PORT/g" |\
    sed -e "s/@BACKEND_ADDRESS/$BACKEND_ADDRESS/g" |\
    sed -e "s/@BACKEND_PORT/$BACKEND_PORT/g" |\
    sed -e "s/@SSL_CERT/$SSL_CERT/g" | \
    sed -e "s/@SSL_KEY/$SSL_KEY/g" > ./backends.d/$NAME.conf

else

    sed -e "s/@MASTER_SLUG/$MASTER_SLUG/g" backend-nginx.conf.template |\
    sed -e "s/@NAME/$NAME/g" |\
    sed -e "s/@FRONTEND_ADDRESS/$FRONTEND_ADDRESS/g" |\
    sed -e "s/@HOSTNAME/$HOSTNAME/g" | \
    sed -e "s/@SERVER_NAME/$SERVER_NAME/g" | \
    sed -e "s/@CLUSTER_ADDRESS/$CLUSTER_ADDRESS/g" |\
    sed -e "s/@CLUSTER_PORT/$CLUSTER_PORT/g" |\
    sed -e "s/@BACKEND_ADDRESS/$BACKEND_ADDRESS/g" |\
    sed -e "s/@BACKEND_PORT/$BACKEND_PORT/g" |\
    sed -e "s/@SSL_CERT/$SSL_CERT/g" | \
    sed -e "s/@SSL_KEY/$SSL_KEY/g" > ./backends.d/$NAME.conf

    echo "Creating ./backends.d/$NAME.location"

    sed -e "s/@MASTER_SLUG/$MASTER_SLUG/g" backend-nginx.location.template |\
    sed -e "s/@NAME/$NAME/g" |\
    sed -e "s/@FRONTEND_ADDRESS/$FRONTEND_ADDRESS/g" |\
    sed -e "s/@HOSTNAME/$HOSTNAME/g" | \
    sed -e "s/@SERVER_NAME/$SERVER_NAME/g" | \
    sed -e "s/@CLUSTER_ADDRESS/$CLUSTER_ADDRESS/g" |\
    sed -e "s/@CLUSTER_PORT/$CLUSTER_PORT/g" |\
    sed -e "s/@BACKEND_ADDRESS/$BACKEND_ADDRESS/g" |\
    sed -e "s/@BACKEND_PORT/$BACKEND_PORT/g" |\
    sed -e "s/@SSL_CERT/$SSL_CERT/g" | \
    sed -e "s/@SSL_KEY/$SSL_KEY/g" > ./backends.d/$NAME.location
fi

mkdir -p ./start.d

echo "Creating ./start.d/$NAME.sh"

    sed -e "s/@MASTER_SLUG/$MASTER_SLUG/g" backend-start.sh.template |\
    sed -e "s/@NAME/$NAME/g" |\
    sed -e "s/@FRONTEND_ADDRESS/$FRONTEND_ADDRESS/g" |\
    sed -e "s/@HOSTNAME/$HOSTNAME/g" | \
    sed -e "s/@SERVER_NAME/$SERVER_NAME/g" | \
    sed -e "s/@CLUSTER_ADDRESS/$CLUSTER_ADDRESS/g" |\
    sed -e "s/@CLUSTER_PORT/$CLUSTER_PORT/g" |\
    sed -e "s/@BACKEND_ADDRESS/$BACKEND_ADDRESS/g" |\
    sed -e "s/@BACKEND_PORT/$BACKEND_PORT/g" |\
    sed -e "s/@SSL_CERT/$SSL_CERT/g" | \
    sed -e "s/@SSL_KEY/$SSL_KEY/g" > ./start.d/$NAME.sh

chmod +x ./start.d/$NAME.sh

