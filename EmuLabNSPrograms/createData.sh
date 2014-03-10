mkdir /mnt/AmazonReview
scp mghosh4@altocumulus.cloud.cs.illinois.edu:/project/mongo-db-query/Dataset/default.csv /mnt/AmazonReview/
scp mghosh4@altocumulus.cloud.cs.illinois.edu:/project/mongo-db-query/Dataset/final.csv /mnt/AmazonReview/
cp /mnt/AmazonReview/default.csv /mnt/AmazonReview/100mb.csv
cp /mnt/AmazonReview/default.csv /mnt/AmazonReview/1gb.csv
cp /mnt/AmazonReview/default.csv /mnt/AmazonReview/2gb.csv
cp /mnt/AmazonReview/default.csv /mnt/AmazonReview/5gb.csv
cp /mnt/AmazonReview/default.csv /mnt/AmazonReview/10gb.csv
cp /mnt/AmazonReview/default.csv /mnt/AmazonReview/15gb.csv
cp /mnt/AmazonReview/default.csv /mnt/AmazonReview/20gb.csv
head -116550    /mnt/AmazonReview/final.csv >> /mnt/AmazonReview/100mb.csv
head -1193047   /mnt/AmazonReview/final.csv >> /mnt/AmazonReview/1gb.csv
head -2386093   /mnt/AmazonReview/final.csv >> /mnt/AmazonReview/2gb.csv
head -5965300   /mnt/AmazonReview/final.csv >> /mnt/AmazonReview/5gb.csv
head -11930500  /mnt/AmazonReview/final.csv >> /mnt/AmazonReview/10gb.csv
head -17895700  /mnt/AmazonReview/final.csv >> /mnt/AmazonReview/15gb.csv
head -23860930  /mnt/AmazonReview/final.csv >> /mnt/AmazonReview/20gb.csv
