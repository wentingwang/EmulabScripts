mkdir /mnt/AmazonReview
scp mghosh4@altocumulus.cloud.cs.illinois.edu:/project/mongo-db-query/Dataset/default.csv /mnt/AmazonReview/
scp mghosh4@altocumulus.cloud.cs.illinois.edu:/project/mongo-db-query/Dataset/final.csv /mnt/AmazonReview/
sh splitfile.sh 20
