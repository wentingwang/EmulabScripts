#! /bin/bash
 
############################## PRE PROCESSING ################################
#check and process arguments
REQUIRED_NUMBER_OF_ARGUMENTS=2
if [ $# -lt $REQUIRED_NUMBER_OF_ARGUMENTS ]
then
    echo "Usage: $0 <type_of_start> <path_to_config_file>"
    echo "Type of start: -h for hard, -s for soft"
    exit 1
fi
 
if [ "$1" == "-h" ]
then
    TYPE_OF_START=1
elif [ "$1" == "-s" ]
then
    TYPE_OF_START=0
else
    echo "Unrecongized start type: -h for hard, -s for soft"
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
QUERY_ROUTER_STRING="sudo $MONGOS --fork --logappend --logpath "$LOG_FOLDER"mongoQueryRouter.log --configdb "
NEW_CONFIG_SERVERS=''
counter=0
for node in ${CONFIG_SERVERS//,/ }
do
    if [ "$IP" == "TRUE" -o "$FQDN" == "TRUE" ] 
    then
        CONFIG_SERVER_FQDN=$node
    else
        CONFIG_SERVER_FQDN=$node.$EXPERIMENT.$PROJ.$ENV
    fi
 
    NEW_CONFIG_SERVERS=$NEW_CONFIG_SERVERS$CONFIG_SERVER_FQDN,
     
    if [ $counter -gt 0 ]
    then
        QUERY_ROUTER_STRING=$QUERY_ROUTER_STRING,
    else
        let counter=counter+1
    fi
    QUERY_ROUTER_STRING=$QUERY_ROUTER_STRING$CONFIG_SERVER_FQDN:$CONFIG_SERVER_PORT
done
 
#construct the query router FQDNs
NEW_QUERY_ROUTERS=''
for node in ${QUERY_ROUTERS//,/ }
do
    if [ "$IP" == "TRUE" -o "$FQDN" == "TRUE" ] 
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
            if [ "$IP" == "TRUE" -o "$FQDN" == "TRUE" ] 
            then
                NEW_REPLICA_SETS=$NEW_REPLICA_SETS$node
            else
                NEW_REPLICA_SETS=$NEW_REPLICA_SETS$node.$EXPERIMENT.$PROJ.$ENV
            fi
        done
        NEW_REPLICA_SETS=$NEW_REPLICA_SETS";"
done
 
############################## SETUP ################################
#setup the config servers
counter=0
echo "Setting up config servers:"
for  node in ${NEW_CONFIG_SERVERS//,/ }
do
        echo "Setting up $node ..."
        COMMAND=''
        if [ $TYPE_OF_START -eq 1 ]
        then
            COMMAND=$COMMAND"sudo mkdir -p "$CONFIG_SERVER_DB_FOLDER"configdb$counter;"
        fi
        COMMAND=$COMMAND" sudo $MONGOD --configsvr --fork --logappend --logpath "$LOG_FOLDER"mongoConfigServer$counter.log --dbpath "$CONFIG_SERVER_DB_FOLDER"configdb$counter --port "$CONFIG_SERVER_PORT
        if [ "$IP" == "TRUE" ]
        then
            COMMAND=$COMMAND" --bind_ip $node;"
        else
            COMMAND=$COMMAND";"
        fi
        echo "Config server startup command is $COMMAND"
        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
            $COMMAND"
        let counter=counter+1;
done
echo ""
 
#setup the replica sets
echo "Setting up replica sets:"
counter=0
for set in ${NEW_REPLICA_SETS//;/ }
do
        echo "Set $counter: "
        port=$REPLICA_SET_START_PORT
        replNum=0
        for node in ${set//,/ }
        do
            echo "Setting up $node ..."
            COMMAND=''
            if [ $TYPE_OF_START -eq 1 ]
            then
                COMMAND=$COMMAND"sudo mkdir -p "$SERVER_DB_FOLDER"rs$counter-$replNum;"
            fi
            COMMAND=$COMMAND" sudo $MONGOD --port $port --fork --logappend --smallfiles --logpath "$LOG_FOLDER"mongors$counter-$replNum.log --dbpath "$SERVER_DB_FOLDER"rs$counter-$replNum --replSet rs$counter -oplogSize 128"
            if [ "$IP" == "TRUE" ]
            then
                COMMAND=$COMMAND" --bind_ip $node;"
            else
                COMMAND=$COMMAND";"
            fi
            echo "Replica startup command is $COMMAND"
            ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
                $COMMAND"
            let replNum=replNum+1;
            let port=port+1;
        done
        let LAST_REPLICA_INDEX=replNum-1;
        echo ""
        let counter=counter+1;
done
 
#setup the query routers
echo "Setting up query routers:"
echo "Router startup string is $QUERY_ROUTER_STRING"
for  node in ${NEW_QUERY_ROUTERS//,/ }
do
        echo "Setting up $node ..."
        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
            $QUERY_ROUTER_STRING"
        queryRouter=$node
done
echo ""
 
if [ $TYPE_OF_START -eq 1 ]
then
    ####################### REPLICATION ######################
    #setup the replicas
    #echo "Sleeping for a minute waiting for all servers to come up.."
    #sleep 120
    RETURN='
    '
    counter=0
    for set in ${NEW_REPLICA_SETS//;/ }
    do
            port=$REPLICA_SET_START_PORT
            replNum=0
            CONTENTS=""
            for node in ${set//,/ }
            do
                if [ $replNum -eq 0 ]
                then
                    INIT="rsconf = {_id: \"rs$counter\",members: [{_id: 0,host: \"$node:$port\"}]}"
                    INIT="$INIT${RETURN}rs.initiate(rsconf)"
                    replicaSetAddNodes[$counter]=$node
                    startNode=$node
                elif [[ ($replNum -eq $LAST_REPLICA_INDEX ) && ("$ARBITERS" == "TRUE") ]]
                then
                    COMMAND="rs.addArb(\"$node:$port\")"
                    CONTENTS="$CONTENTS$COMMAND${RETURN}"
                else
                    COMMAND="rs.add(\"$node:$port\")"
                    CONTENTS="$CONTENTS$COMMAND${RETURN}"
                fi
                let replNum=replNum+1;  
                let port=port+1;
                 
            done
            echo "$INIT" > rs$counter-init.js
            echo "$CONTENTS" > rs$counter-add.js
            echo "Running $MONGO --host $startNode --port $REPLICA_SET_START_PORT < rs$counter-init.js"
            EXIT_STATUS=1
            RESPONSE="y"
            while [ $EXIT_STATUS -eq 1 -a "$RESPONSE" == "y" ]
            do
                $MONGO --host $startNode --port $REPLICA_SET_START_PORT < rs$counter-init.js
                EXIT_STATUS=$?
                if [ $EXIT_STATUS -eq 1 ]
                then
                    echo "Command failed. Try again? (y or n)"
                    read RESPONSE
                fi
            done
            let counter=counter+1;
    done
    echo "Sleeping for a minute waiting for the initiation of the replica sets to finish..."
    sleep 120
    counter=0
    for set in ${NEW_REPLICA_SETS//;/ }
    do
            startNode=${replicaSetAddNodes[$counter]}
            echo "$MONGO --host $startNode --port $REPLICA_SET_START_PORT < rs$counter-add.js"
            EXIT_STATUS=1
            RESPONSE="y"
            while [ $EXIT_STATUS -eq 1 -a "$RESPONSE" == "y" ]
            do
                $MONGO --host $startNode --port $REPLICA_SET_START_PORT < rs$counter-add.js
                EXIT_STATUS=$?
                if [ $EXIT_STATUS -eq 1 ]
                then
                    echo "Command failed. Try again? (y or n)"
                    read RESPONSE
                fi
            done
            let counter=counter+1
    done
 
    ####################### SHARDING #########################
    #setup the shards
    CONTENTS=""
    RETURN='
    '
    counter=0
    for set in ${NEW_REPLICA_SETS//;/ }
    do
            for node in ${set//,/ }
            do
                COMMAND=sh.addShard\(\"rs$counter/$node:$REPLICA_SET_START_PORT\"\)
                CONTENTS="$CONTENTS$COMMAND${RETURN}"  
                break
            done
            let counter=counter+1;
    done
    echo "$CONTENTS" > shard.js
    echo "Running $MONGO --host $queryRouter --port 27017 < shard.js"
    EXIT_STATUS=1
    RESPONSE="y"
    while [ $EXIT_STATUS -eq 1 -a "$RESPONSE" == "y" ]
    do
        $MONGO --host $queryRouter --port 27017 < shard.js
        EXIT_STATUS=$?
        if [ $EXIT_STATUS -eq 1 ]
        then
            echo "Command failed. Try again? (y or n)"
            read RESPONSE
        fi
    done
fi
