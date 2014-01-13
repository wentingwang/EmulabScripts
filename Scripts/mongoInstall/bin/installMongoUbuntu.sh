A=`cat /etc/lsb-release | grep DISTRIB_RELEASE | cut -d "=" -f2 | bc`
echo "Ubuntu version is $A"
KARMIC=9.04
UPSTART=`echo "$A > $KARMIC" | bc`
if [ "$UPSTART" -eq 1 ] 
then
	echo "Performing upstart install"
        /usr/bin/sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 7F0CEB10
	if [ $? != 0 ]
        then
                echo "Failed to add public key to system key ring"
                exit 1
        fi
        echo 'deb http://downloads-distro.mongodb.org/repo/ubuntu-upstart dist 10gen' | /usr/bin/sudo tee /etc/apt/sources.list.d/mongodb.list
	if [ $? != 0 ]
        then
                echo "Failed to add mongoDB to sources list"
                exit 1
        fi
else
	echo "Performing non upstart install"
	/usr/bin/sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
	if [ $? != 0 ]
	then
		echo "Failed to add public key to system key ring"
		exit 1
	fi
	echo 'deb http://downloads-distro.mongodb.org/repo/debian-sysvinit dist 10gen' | /usr/bin/sudo tee /etc/apt/sources.list.d/mongodb.list
	if [ $? != 0 ]
        then
                echo "Failed to add mongoDB to sources list"
                exit 1
        fi
fi
/usr/bin/sudo apt-get update
if [ $? != 0 ]
then
	echo "Failed to get update repository"
        exit 1
fi
/usr/bin/sudo apt-get install mongodb-10gen
if [ $? != 0 ]
then
        echo "Failed to install MongoDB"
        exit 1
fi

exit 0
