source $1
mongoexport --host $QUERY_ROUTERS  --db amazondb --collection review_collection --out temp.json

DELETE_COLLECTION = "use amazondb${RETURN} db.review_collection.drop()${RETURN}"
echo "$DELETE_COLLECTION" > drop_colleciton.js

RESHARD = "sh.shardCollection\(\"amazondb.review_collection\",{user_id:1}\)"
echo "$RESHARD" > reshard.js

mongo --host $QUERY_ROUTERS < drop_collection.js
