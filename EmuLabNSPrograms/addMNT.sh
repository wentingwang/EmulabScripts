#!/bin/sh
for (( i=0; i<=$1; i++ ))
do
    echo "Setting up node$i.mongodb.iss.emulab.net"
	ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no node-$i.mongodb.iss.emulab.net "sudo /usr/testbed/bin/mkextrafs /mnt"
done
