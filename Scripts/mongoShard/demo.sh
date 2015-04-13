#! /bin/bash

function progress {
		time=$1
                echo $time
		SOFAR=0
                finish=false
                while  [ $SOFAR -lt 100 ] && [ "$finish"==false ]
                do
                    sharp=""
                    random=$[ 1 + $[ RANDOM % 10 ]]
                    let SOFAR=SOFAR+random
                    if [ $SOFAR -gt 100 ]
                    then
                        SOFAR=100
                    	finish=true
                    fi

                    for (( c=1; c<=$[$[ $SOFAR * 40 ] / 100]; c++ ))
                    do
                        sharp=$sharp"#"
                    done
                    echo -ne "$sharp($SOFAR%)\r"
		    sleep $[ $[$random * $time ] / 100 ]
                    #echo $[ $[$random * $time ] / 100 ]
                done
		echo -ne '\n'
         }

echo "MongoDB Shell version: 2.4.13"
echo "connect to: test"
printf "mongos>"

read cmd
echo $cmd

if [ "$cmd" == "reshard" ]
then
	progress 100
fi



