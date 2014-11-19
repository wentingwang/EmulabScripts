sh.enableSharding("amazondb")
sh.shardCollection("amazondb.review_collection",{user_id:1})
