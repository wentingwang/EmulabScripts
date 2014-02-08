use testdb
sh.enableSharding("testdb")
db.test_collection.ensureIndex({user_id:1})
db.test_collection.ensureIndex({number:1}) 
sh.shardCollection("testdb.test_collection",{user_id:1})
