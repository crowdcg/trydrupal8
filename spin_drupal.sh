#!/bin/bash

#HIPACHE location gets passed in
REDIS_HOST=$1
REDIS_PORT=$2
HIPACHE_PORT=$3
BRIDGE_IP=$4

#start the container and pass in the necessary environment variables for the app to run
DRUPAL8_CONTAINER=$(docker run -d -p 80 -e HIPACHE_PORT=$HIPACHE_PORT -e REDIS_HOST=$REDIS_HOST -e REDIS_PORT=$REDIS_PORT -e DOCKER_HOST=$BRIDGE_IP nickgs/drupal8 /usr/bin/supervisord)
DRUPAL8_HOST=$BRIDGE_IP
#get the port that the flask app is running on so as to route effectively.
DRUPAL8_PORT=$(docker port $TRYRETHINK_CONTAINER 80)

# redis takes a bit of time to load up...
sleep 5

#print out the container ID
echo $DRUPAL8_CONTAINER

#make sure the main hipache knows about our new http://tryrethink.info domain.`
redis-cli -h $REDIS_HOST -p $REDIS_PORT rpush frontend:$DRUPAL8_CONTAINER.trydrupal8.dev $DRUPAL8_CONTAINER.trydrupal8
redis-cli -h $REDIS_HOST -p $REDIS_PORT rpush frontend:$DRUPAL8_CONTAINER.trydrupal8.dev http://$DRUPAL8_HOST:$DRUPAL8_PORT