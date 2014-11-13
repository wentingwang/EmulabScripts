for ((i=$1; i<=$2; i++))
do
    echo Starting $i mongoimport
    .EmulabScripts/TestingScripts/_Runners/addDataAmazon.sh part_$i.csv &
done

while true
do
    count=`ps -aef | grep mongoimport | wc -l`
    if [ $count -eq 1 ]
    then
        break
    fi
    echo "Adding data. Number of instances left: " $count
    sleep 60
done
