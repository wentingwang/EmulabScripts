REQUIRED_NUMBER_OF_ARGUMENTS=1
if [ $# -lt $REQUIRED_NUMBER_OF_ARGUMENTS ]
then
	echo "Usage: $0 <name_of_csv_file>"
	exit 1
fi
./shardCollectionAmazon.sh
./addDataParallelAmazon.sh $1
./statsAmazon.sh
echo "Sleeping for 30 minute waiting for the data to be replicated"
sleep 1800
./shardStatus.sh
./reshardAmazon.sh
./shardStatus.sh
