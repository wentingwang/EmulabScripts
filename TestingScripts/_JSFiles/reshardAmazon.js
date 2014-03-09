use amazondb
db.review_collection.ensureIndex({user_id:1}) 
sh.reShardCollection("amazondb.review_collection",{user_id:1})
//sh.reShardCollection("amazondb.review_collection",{ReviewID:1})
