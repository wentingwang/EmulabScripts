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

############################## PROCESS CONFIG FILE ################################

#construct the config server FQDNs
#build the command for the query router in the process
CONFIG_DB_STRING=' '
NEW_CONFIG_SERVERS=''
counter=0
for node in ${CONFIG_SERVERS//,/ }
do
	NEW_CONFIG_SERVERS=$NEW_CONFIG_SERVERS$node.$EXPERIMENT.$PROJ.$ENV,
	
	if [ $counter -gt 0 ]
	then
		CONFIG_DB_STRING=$CONFIG_DB_STRING,
	else
		let counter=counter+1
	fi
	CONFIG_DB_STRING=$CONFIG_DB_STRING$node.$EXPERIMENT.$PROJ.$ENV:$CONFIG_SERVER_PORT
done

#construct the query router FQDNs
NEW_QUERY_ROUTERS=''
for node in ${QUERY_ROUTERS//,/ }
do
        NEW_QUERY_ROUTERS=$NEW_QUERY_ROUTERS$node.$EXPERIMENT.$PROJ.$ENV,
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
        	NEW_REPLICA_SETS=$NEW_REPLICA_SETS$node.$EXPERIMENT.$PROJ.$ENV
		done
		NEW_REPLICA_SETS=$NEW_REPLICA_SETS";"
done

############################ SHUTDOWN ##########################################
#shutdown the config servers
echo "Shutting down config servers:"
for  node in ${NEW_CONFIG_SERVERS//,/ }
do
        echo "Shutting down $node ..."
        COMMAND='sudo mongod --shutdown --dbpath /data/configdb;'
        if [ $TYPE_OF_STOP -eq 1 ]
        then
        	COMMAND=$COMMAND"sudo rm /var/log/mongoConfigServer.log;sudo rm -rf /data/configdb;"
        fi
        echo $COMMAND
		ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
			$COMMAND"
done
echo ""

#shutdown the query routers
echo "Shutting down query routers:"
for  node in ${NEW_QUERY_ROUTERS//,/ }
do
        echo "Shutting down $node ..."
        COMMAND='sudo pkill mongos;'
        if [ $TYPE_OF_STOP -eq 1 ]
        then
        	COMMAND=$COMMAND"sudo rm /var/log/mongoQueryRouter.log;"
        fi
        echo $COMMAND
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
        	COMMAND='sudo mongod --shutdown --dbpath /srv/mongodb/rs$counter-$replNum;'
        	if [ $TYPE_OF_STOP -eq 1 ]
        	then
        		COMMAND=$COMMAND"sudo rm -rf /srv/mongodb/rs$counter-$replNum;sudo rm /var/log/mongors$counter-$replNum.log;"
        	fi
        	echo $COMMAND
	        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
	        	$COMMAND"
			let replNum=replNum+1;
		done
		echo ""
		let counter=counter+1;
done