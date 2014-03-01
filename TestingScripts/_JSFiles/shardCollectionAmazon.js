use amazondb
sh.enableSharding("amazondb")
db.review_collection.ensureIndex({ReviewID:1})
db.review_collection.ensureIndex({ProductID:1}) 
sh.shardCollection("amazondb.review_collection",{ReviewID:1})