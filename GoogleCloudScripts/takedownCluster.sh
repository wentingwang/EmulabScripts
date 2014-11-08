#!/bin/bash

if [ $# -le 2 ]; then
	echo "Usage: ./takedownCluster.sh -n <number of instances> -r <1 for remove disk/ any other number otherwise>"
	exit
fi

NUM_INSTANCE=0
REMOVE_DISK=0
NAME_PREFIX="node"
while [[ $# > 1 ]]
do
key="$1"
shift

case $key in
    -n|--num_instance)
    NUM_INSTANCE="$1"
    shift
    ;;
    -r|--remove_disk)
    REMOVE_DISK="$1"
    shift
    ;;
    -p|--name_prefix)
    NAME_PREFIX="$1"
    shift
    ;;
    *)
            # unknown option
    ;;
esac
done

node_array=""
for (( i=1; i<=$NUM_INSTANCE; i++ ))
do
    node_array="$node_array $NAME_PREFIX$i"
done
echo "gcloud compute instances delete $node_array --zone us-central1-a"
gcloud compute instances delete $node_array --zone us-central1-a --project ferrous-osprey-732

if [ $REMOVE_DISK -eq 1 ]; then
	echo "gcloud compute disks delete datadisk --zone us-central1-a"
	gcloud compute disks delete datadisk --zone us-central1-a
fi
