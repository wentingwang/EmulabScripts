numRows=1193047
echo Creating Part 1.....
cp /mnt/AmazonReview/default.csv /mnt/AmazonReview/part_1.csv
head -$numRows /mnt/AmazonReview/final.csv >> /mnt/AmazonReview/part_1.csv
for ((i=2; i<=$1; i++))
do
    cp /mnt/AmazonReview/default.csv /mnt/AmazonReview/part_$i.csv
    head=`echo "$i * $numRows" | bc -l`
    echo Creating Part $i.....$head
    head -$head /mnt/AmazonReview/final.csv | tail -$numRows >> /mnt/AmazonReview/part_$i.csv
done
