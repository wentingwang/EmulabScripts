source $1

QUERY_ROUTER_STRING="/mnt/wmongo/mongo --host localhost --port 27017 < /home/wenting/EmulabScripts/TestingScripts/_JSFiles/generateData.js"
GIT_STRING="git clone http://github.com/wentingwang/EmulabScripts"
REMOVE_STRING="sudo rm -rf EmulabScripts"
for  node in ${QUERY_ROUTERS//,/ }
do
        echo "clone git hub to $node ... $REMOVE_STRING"
        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
            $REMOVE_STRING" &
         echo "clone git hub to $node ... $GIT_STRING"
        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
            $GIT_STRING" &
        #echo "loading data to $node ... $QUERY_ROUTER_STRING"
        #ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
        #    $QUERY_ROUTER_STRING" &
done
echo ""
