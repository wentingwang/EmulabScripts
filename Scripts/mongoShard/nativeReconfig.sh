#! /bin/bash
source "$1"
echo $1
mongoexport --host $QUERY_ROUTERS  --db amazondb --collection review_collection --out temp.json

DELETE_COLLECTION="use amazondb\n db.review_collection.drop()"
echo -e "$DELETE_COLLECTION" > drop_collection.js

RESHARD="sh.enableSharding(\"amazondb\")\ndb.review_collection.ensureIndex({number:1})\nsh.shardCollection(\"amazondb.review_collection\",{number:1})"
echo -e "$RESHARD" > reshard.js

mongo --host $QUERY_ROUTERS < drop_collection.js
