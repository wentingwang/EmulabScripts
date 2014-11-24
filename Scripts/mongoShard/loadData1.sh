source $1

QUERY_ROUTER_STRING="/mnt/mongo/mongo --host localhost --port 27018 < /home/wenting/EmulabScripts/TestingScripts/_JSFiles /generateData.js"
GIT_STRING="git clone https://github.com/wentingwang/EmulabScripts.git"
for  node in ${QUERY_ROUTERS//,/ }
do
        echo "loading data to $node ... $GIT_STRING"
        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
            $QUERY_ROUTER_STRING" &
done
echo ""
