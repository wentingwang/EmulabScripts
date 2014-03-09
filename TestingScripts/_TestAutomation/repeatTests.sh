REQUIRED_NUMBER_OF_ARGUMENTS=2
if [ $# -lt $REQUIRED_NUMBER_OF_ARGUMENTS ]
then
	echo "Usage: $0 <experiment_name> <number_of_times_to_repeat_test>"
	exit 1
fi

NUM_TIMES=$2

for i in `seq 1 $NUM_TIMES`
do
	echo "Running iteration: $i"
	echo ""
	./runTest.sh $1 $i
done
