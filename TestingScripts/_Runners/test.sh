#!/bin/bash
source details.conf
MONGO=$PATH_TO_MONGO_BIN"mongo"
JS_FILE=$JS_FILES_LOCATION"test.js"
$MONGO --host $ROUTER_IP --port $ROUTER_PORT < $JS_FILE
