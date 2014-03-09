sh.enableSharding("amazondb")
sh.shardCollection("amazondb.review_collection",{product_id:1})
