#! /bin/bash
source "$1"
echo $1
export_start='date +%s'
mongoexport --host $QUERY_ROUTERS  --db amazondb --collection review_collection --out temp.json
export_end='date +%s'
runtime=$((export_end-export_start))
echo "export time=$runtime"

DELETE_COLLECTION="use amazondb\n db.review_collection.drop()"
echo -e "$DELETE_COLLECTION" > drop_collection.js

RESHARD="sh.enableSharding(\"amazondb\")\ndb.review_collection.ensureIndex({number:1})\nsh.shardCollection(\"amazondb.review_collection\",{number:1})"
echo -e "$RESHARD" > reshard.js

delete_start='date +%s'
mongo --host $QUERY_ROUTERS < drop_collection.js
delete_end='date +%s'
runtime=$((delete_end-delete_start))
echo "delete time=$runtime"

reshard_start='date +%s'
mongo --host $QUERY_ROUTERS < reshard.js
reshard_end='date +%s'
runtime=$((reshard_end-reshard_start))
echo "reshard time=$runtime"

import_start='date +%s'
mongoimport --host $QUERY_ROUTERS --db amazondb --collection review_collection --file temp.json
import_end='date +%s'
runtime=$((import_end-import_start))
echo "import time=$runtime"
