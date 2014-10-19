#!/bin/bash

REQUIRED_NUMBER_OF_ARGUMENTS=1
if [ $# -lt $REQUIRED_NUMBER_OF_ARGUMENTS ]
then
	echo "Usage: $0 <path_to_csv_file>"
	exit 1
fi

source details.conf
PATH_TO_DATA_FILE=$DATASET_FILES_LOCATION$1
mongoimport --host $ROUTER_IP --port $ROUTER_PORT --db amazondb --collection review_collection --type csv --file $PATH_TO_DATA_FILE --headerline
