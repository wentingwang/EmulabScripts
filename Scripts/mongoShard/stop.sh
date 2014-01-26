#! /bin/bash

############################## PRE PROCESSING ################################
#check and process arguments
REQUIRED_NUMBER_OF_ARGUMENTS=2
if [ $# -lt $REQUIRED_NUMBER_OF_ARGUMENTS ]
then
	echo "Usage: $0 <type_of_stop> <path_to_config_file>"
	echo "Type of stop: -h for hard, -s for soft"
	exit 1
fi

if [ "$1" == "-h" ]
then
	TYPE_OF_STOP=1
elif [ "$1" == "-s" ]
then
	TYPE_OF_STOP=0
else
	echo "Unrecongized stop type: -h for hard, -s for soft"
	exit 1
fi

CONFIG_FILE=$2

echo "Config file is $CONFIG_FILE"
echo ""

#get the configuration parameters
source $CONFIG_FILE

MONGOD=$PATH_TO_MONGO_BIN"mongod"
MONGOS=$PATH_TO_MONGO_BIN"mongos"
MONGO=$PATH_TO_MONGO_BIN"mongo"

############################## PROCESS CONFIG FILE ################################

#construct the config server FQDNs
#build the command for the query router in the process
CONFIG_DB_STRING=' '
NEW_CONFIG_SERVERS=''
counter=0
for node in ${CONFIG_SERVERS//,/ }
do
	if [ "$IP" == "TRUE" ] 
	then
		CONFIG_SERVER_FQDN=$node
	else
		CONFIG_SERVER_FQDN=$node.$EXPERIMENT.$PROJ.$ENV
	fi
	NEW_CONFIG_SERVERS=$NEW_CONFIG_SERVERS$CONFIG_SERVER_FQDN,
	
	if [ $counter -gt 0 ]
	then
		CONFIG_DB_STRING=$CONFIG_DB_STRING,
	else
		let counter=counter+1
	fi
	CONFIG_DB_STRING=$CONFIG_DB_STRING$CONFIG_SERVER_FQDN:$CONFIG_SERVER_PORT
done

#construct the query router FQDNs
NEW_QUERY_ROUTERS=''
for node in ${QUERY_ROUTERS//,/ }
do
    if [ "$IP" == "TRUE" ] 
	then
		NEW_QUERY_ROUTERS=$NEW_QUERY_ROUTERS$node,
	else
        NEW_QUERY_ROUTERS=$NEW_QUERY_ROUTERS$node.$EXPERIMENT.$PROJ.$ENV,
    fi
done

#construct the replica sets FQDNs
NEW_REPLICA_SETS=''
for set in ${REPLICA_SETS//;/ }
do
        counter=0
        for node in ${set//,/ }
		do
        	if [ $counter -gt 0 ]
			then
				NEW_REPLICA_SETS=$NEW_REPLICA_SETS,
			else
				let counter=counter+1
			fi
        	if [ "$IP" == "TRUE" ] 
			then
				NEW_REPLICA_SETS=$NEW_REPLICA_SETS$node
			else
        		NEW_REPLICA_SETS=$NEW_REPLICA_SETS$node.$EXPERIMENT.$PROJ.$ENV
        	fi
		done
		NEW_REPLICA_SETS=$NEW_REPLICA_SETS";"
done

############################ SHUTDOWN ##########################################
#shutdown the config servers
echo "Shutting down config servers:"
counter=0
for  node in ${NEW_CONFIG_SERVERS//,/ }
do
        echo "Shutting down $node ..."
        COMMAND="sudo $MONGOD --shutdown --dbpath "$CONFIG_SERVER_DB_FOLDER"configdb$counter;"
        if [ $TYPE_OF_STOP -eq 1 ]
        then
        	COMMAND=$COMMAND"sudo rm "$LOG_FOLDER"mongoConfigServer$counter.log;sudo rm -rf "$CONFIG_SERVER_DB_FOLDER"configdb;"
        fi
        echo "Config server shutdown command is $COMMAND"
		ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
			$COMMAND"
		let counter=counter+1;
done
echo ""

#shutdown the query routers
echo "Shutting down query routers:"
for  node in ${NEW_QUERY_ROUTERS//,/ }
do
        echo "Shutting down $node ..."
        COMMAND="sudo pkill $MONGOS;"
        if [ $TYPE_OF_STOP -eq 1 ]
        then
        	COMMAND=$COMMAND"sudo rm "$LOG_FOLDER"mongoQueryRouter.log;"
        fi
        echo "Query router shutdown command is $COMMAND"
        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
        	$COMMAND"
done
echo ""

#shutdown the replica sets
echo "Shutting down replica sets:"
counter=0
for set in ${NEW_REPLICA_SETS//;/ }
do
        echo "Set $counter: "
        replNum=0
        for node in ${set//,/ }
		do
        	echo "Shutting down $node ..."
        	COMMAND="sudo $MONGOD --shutdown --dbpath "$SERVER_DB_FOLDER"rs$counter-$replNum;"
        	if [ $TYPE_OF_STOP -eq 1 ]
        	then
        		COMMAND=$COMMAND"sudo rm -rf "$SERVER_DB_FOLDER"rs$counter-$replNum;sudo rm "$LOG_FOLDER"mongors$counter-$replNum.log;"
        	fi
        	echo "Replica set shutdown command is $COMMAND"
	        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
	        	$COMMAND"
			let replNum=replNum+1;
		done
		echo ""
		let counter=counter+1;
done