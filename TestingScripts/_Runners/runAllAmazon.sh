REQUIRED_NUMBER_OF_ARGUMENTS=1
if [ $# -lt $REQUIRED_NUMBER_OF_ARGUMENTS ]
then
	echo "Usage: $0 <name_of_csv_file>"
	exit 1
fi
./shardCollectionAmazon.sh
./addDataParallelAmazon.sh $1
./statsAmazon.sh
echo "Checking whether data is stable"
./collectionStableAmazon.sh $1
./shardStatus.sh
./reshardAmazon.sh
./shardStatus.sh
