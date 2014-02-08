#! /bin/bash

if [ $# -lt 1 ]
	then
	echo "Usage: $0 <mongo_command>"
	exit 1
fi

COMMAND=$1
source details.conf
MONGO=$PATH_TO_MONGO_BIN"mongo"

EXECUTE=TRUE
case $COMMAND in
	"connect")	echo "Connecting to router at $ROUTER_IP:$ROUTER_PORT.."
				EXECUTE=FALSE
				$MONGO --host $ROUTER_IP --port $ROUTER_PORT;;
	"connectd")      echo "Connecting to router at $RS_0_IP:$RS_PORT.."
                                EXECUTE=FALSE
                                $MONGO --host $RS_0_IP --port $RS_PORT;;
	"shardStatus")	echo "Printing sharding status.."
					JS_FILE=$JS_FILES_LOCATION"shardStatus.js";;
	"genFind")	echo "Doing a general find.."
				JS_FILE=$JS_FILES_LOCATION"genFind.js";;
	"rsConfig") echo "Showing replica set configs.."
				EXECUTE=FALSE
				JS_FILE=$JS_FILES_LOCATION"rsConfig.js"
				$MONGO --host $RS_0_IP --port $RS_PORT < $JS_FILE
				$MONGO --host $RS_1_IP --port $RS_PORT < $JS_FILE
				$MONGO --host $RS_2_IP --port $RS_PORT < $JS_FILE;;
	"rsStatus") echo "Showing replica set status.."
				EXECUTE=FALSE
				JS_FILE=$JS_FILES_LOCATION"rsStatus.js"
				$MONGO --host $RS_0_IP --port $RS_PORT < $JS_FILE
				$MONGO --host $RS_1_IP --port $RS_PORT < $JS_FILE
				$MONGO --host $RS_2_IP --port $RS_PORT < $JS_FILE;;
	*)	echo "Unrecognized command!"
		EXECUTE=FALSE;;
esac

if [ "$EXECUTE" == "TRUE" ]
	then
	$MONGO --host $ROUTER_IP --port $ROUTER_PORT < $JS_FILE
fi
