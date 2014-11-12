#!/bin/bash
sudo mount -o ro,noload /dev/sdb1 /mnt/
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | sudo tee /etc/apt/sources.list.d/mongodb.list
sudo apt-get update
sudo apt-get -y install vim git screen mongodb-org-tools
cd /home/wenting
git clone https://github.com/wentingwang/EmulabScripts
