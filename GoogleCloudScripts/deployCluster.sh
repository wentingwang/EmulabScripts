#!/bin/bash

if [ $# -le 2 ]; then
	echo "Usage: ./deployCluster.sh -n <number of instances> -c <1 for create disk/any number otherwise>"
	exit
fi

while [[ $# > 1 ]]
do
key="$1"
shift

case $key in
    -n|--num_instance)
    NUM_INSTANCE="$1"
    shift
    ;;
    -c|--create_disk)
    ATTACH_DISK="$1"
    shift
    ;;
    *)
            # unknown option
    ;;
esac
done

#Creating a persistent disk

if [ $ATTACH_DISK -eq 1 ]; then
	echo "gcloud compute disks create datadisk --zone us-central1-a --size 1TB"
	gcloud compute disks create datadisk --zone us-central1-a --size 1TB --project ferrous-osprey-732
fi

node_array=""
for (( i=1; i<=$NUM_INSTANCE; i++ ))
do
    node_array="$node_array node$i"
done

echo "gcloud compute instances create $node_array --zone us-central1-a --image centos-6 --machine-type n1-standard-2 --disk name=datadisk mode=ro --project ferrous-osprey-732 --metadata-from-file startup-script=startup.sh"
gcloud compute instances create $node_array --zone us-central1-a --image debian-7 --machine-type n1-standard-2 --disk name=datadisk mode=ro --project ferrous-osprey-732 --metadata-from-file startup-script=startup.sh

#echo "gcloud compute instances attach-disk $node_array --disk datadisk --zone us-central1-a --mode ro"
#gcloud compute instances attach-disk $node_array --disk datadisk --zone us-central1-a --mode ro
