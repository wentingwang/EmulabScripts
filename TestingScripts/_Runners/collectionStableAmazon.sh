numRows=1193047
trueCount=`echo "$1 * $numRows" | bc -l`
echo "True Count " $trueCount
currCount=`./countAmazon.sh | tail -2 | head -1`
echo "Current Count " $currCount
while [ $currCount -gt $trueCount ]
do
    sleep 1
    currCount=`./countAmazon.sh | tail -2 | head -1`
    echo "Current Count " $currCount
done
