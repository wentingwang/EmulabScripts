REQUIRED_NUMBER_OF_ARGUMENTS=1
if [ $# -lt $REQUIRED_NUMBER_OF_ARGUMENTS ]
then
	echo "Usage: $0 <name_of_csv_file>"
	exit 1
fi

source details.conf
PATH_TO_DEFAULT=$DATASET_FILES_LOCATION"default.csv"

if [ -f $PATH_TO_DEFAULT ]
then
	./shardCollectionAmazon.sh &&
	./addDataAmazon.sh $1 &&
    ./statsAmazon.sh &&
	echo "Sleeping for 30 minute waiting for the data to be replicated" &&
	sleep 1800 &&
    ./shardStatus.sh
	./reshardAmazon.sh &&
    ./shardStatus.sh
else
	echo "Need a default.csv that enters exactly one record into the collection"
	exit 2
fi

