source=$1
count=$2
i=1
QUERY_ROUTER_STRING="EmulabScripts/TestingScripts/_Runners/addDataParallelAmazon.sh"
for  node in ${NEW_QUERY_ROUTERS//,/ }
do
        echo "loading data to $node ... $QUERY_ROUTER_STRING $i $((i+count-1))"
        ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no $node "
            $QUERY_ROUTER_STRING $i $((i+count-1))"
        let i=i+count
done
echo ""
