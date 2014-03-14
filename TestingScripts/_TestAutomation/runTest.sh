#!/bin/bash

echo "@@@@@@@@  Starting test  @@@@@@@@@"
echo ""
source automation.conf

echo "#####	Printing conf details #####"

echo "Cluster tools at: $CLUSTER_TOOLS"
echo "Command tools at: $COMMAND_TOOLS"

echo "Cluster config file is: $CLUSTER_SETUP_CONF"
echo "Type of start is: $CLUSTER_START_STOP_TYPE"

echo "Data file which will be loaded: $DATA_FILE"

echo "##### Conf details done #####"
echo ""

if [ "$CLUSTER_START_STOP_TYPE" == "soft" ]
	then
	START_STOP_ARG="-s"
else
	START_STOP_ARG="-h"
fi

echo "#### Bringing up the cluster ####"

START_SCRIPT="./start.sh"
START_COMMAND="$START_SCRIPT $START_STOP_ARG $CLUSTER_SETUP_CONF"
cd $CLUSTER_TOOLS
echo "$START_COMMAND"
$START_COMMAND
cd -


echo "#### Cluster up #####"
echo ""

echo "#### Adding data and running reshard ####"

RESHARD_SCRIPT="./runAllAmazon.sh"
RESHARD_COMMAND="$RESHARD_SCRIPT $1"
echo "$RESHARD_COMMAND"
cd $COMMAND_TOOLS
$RESHARD_COMMAND
cd -

echo "#### Resharding done ####"
echo ""

cd $CLUSTER_TOOLS
source $CLUSTER_SETUP_CONF
cp $LOG_FOLDER/mongoQueryRouter.log $OUT_FOLDER/mongoQueryRouter_$1_$2.log
cd -

echo "#### Copied Log Folder ####"
echo ""

echo "#### Tearing down cluster ####"

STOP_SCRIPT="./stop.sh"
STOP_COMMAND="$STOP_SCRIPT $START_STOP_ARG $CLUSTER_SETUP_CONF"
cd $CLUSTER_TOOLS
echo "$STOP_COMMAND"
$STOP_COMMAND
cd -


echo "#### Cluster down #####"
echo ""

echo "@@@@@@@@  Test done  @@@@@@@@@"
