#!/bin/bash
sudo mount -o ro,noload /dev/sdb1 /mnt/
sudo apt-get update
sudo apt-get -y install vim git screen
cd ~
git clone https://github.com/mghosh4/EmulabScripts
