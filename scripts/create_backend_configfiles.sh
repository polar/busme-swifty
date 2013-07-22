#!/bin/sh -x

echo $0 $*

cd ~/busme-swifty

NAME=$1
MASTER_SLUG=$2
MASTER_ID=$3
FRONTEND_ADDRESS=$4
HOSTNAME=$5
SERVER_NAME=$6
CLUSTER_ADDRESS=$7
CLUSTER_PORT=$8
BACKEND_ADDRESS=$9
BACKEND_PORT=${10}
SSL_CERT=${11}
SSL_KEY=${12}

if [ "x$SSL_CERT" = "x" ]; then
   SSL_CERT=\\/etc\\/ssl\\/certs\\/busme-us.pem
   SSL_KEY=\\/etc\\/ssl\\/certs\\/busme-us.pem
fi


mkdir -p ./backends.d

echo "Creating ./backends.d/$NAME.conf"

if [ "x$MASTER_SLUG" = "x" ]; then
    sed -e "s/@MASTER_SLUG/$MASTER_SLUG/g" base-backend-nginx.conf.template |\
    sed -e "s/@MASTER_ID/$MASTER_ID/g" |\
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
    sed -e "s/@MASTER_ID/$MASTER_ID/g" |\
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
    sed -e "s/@MASTER_ID/$MASTER_ID/g" |\
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

  if [ "x$MASTER_ID" != "x" ]; then
    echo "Creating ./backends.d/$NAME-master-id.location"

    sed -e "s/@MASTER_SLUG/$MASTER_SLUG/g" backend-nginx.master_id_location.template |\
    sed -e "s/@MASTER_ID/$MASTER_ID/g" |\
    sed -e "s/@NAME/$NAME/g" |\
    sed -e "s/@FRONTEND_ADDRESS/$FRONTEND_ADDRESS/g" |\
    sed -e "s/@HOSTNAME/$HOSTNAME/g" | \
    sed -e "s/@SERVER_NAME/$SERVER_NAME/g" | \
    sed -e "s/@CLUSTER_ADDRESS/$CLUSTER_ADDRESS/g" |\
    sed -e "s/@CLUSTER_PORT/$CLUSTER_PORT/g" |\
    sed -e "s/@BACKEND_ADDRESS/$BACKEND_ADDRESS/g" |\
    sed -e "s/@BACKEND_PORT/$BACKEND_PORT/g" |\
    sed -e "s/@SSL_CERT/$SSL_CERT/g" | \
    sed -e "s/@SSL_KEY/$SSL_KEY/g" > ./backends.d/$NAME-master-id.location
  fi
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

