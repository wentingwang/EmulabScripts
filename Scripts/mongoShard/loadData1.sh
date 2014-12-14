source $1

QUERY_ROUTER_STRING="/mnt/wmongo/mongo --host localhost --port 27017 < /home/wenting/EmulabScripts/TestingScripts/_JSFiles/$2"
for  node in ${QUERY_ROUTERS//,/ }
do
        echo "loading data to $node ... $QUERY_ROUTER_STRING"
        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
            $QUERY_ROUTER_STRING" &
done
echo ""
