#!/bin/bash
apt-get update
apt-get install vim git
git clone https://github.com/mghosh4/EmulabScripts
sudo mount -o ro,noload /dev/sdb1 /mnt/
