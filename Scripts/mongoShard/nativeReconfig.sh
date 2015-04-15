#! /bin/bash
source "$1"
echo $1
export_start=$(date +%s.%N)
mongoexport --host $QUERY_ROUTERS  --db amazondb --collection review_collection --out /mnt/temp.json
export_end=$(date +%s.%N)
runtime=$((export_end-export_start))
echo "export time=$runtime"

DELETE_COLLECTION="use amazondb\n db.review_collection.drop()"
echo -e "$DELETE_COLLECTION" > drop_collection.js

RESHARD="sh.enableSharding(\"amazondb\")\ndb.review_collection.ensureIndex({number:1})\nsh.shardCollection(\"amazondb.review_collection\",{number:1})"
echo -e "$RESHARD" > reshard.js

delete_start=$(date +%s.%N)
mongo --host $QUERY_ROUTERS < drop_collection.js
delete_end=$(date +%s.%N)
runtime=$((delete_end-delete_start))
echo "delete time=$runtime"

reshard_start=$(date +%s.%N)
mongo --host $QUERY_ROUTERS < reshard.js
reshard_end=$(date +%s.%N)
runtime=$((reshard_end-reshard_start))
echo "reshard time=$runtime"

import_start=$(date +%s.%N)
mongoimport --host $QUERY_ROUTERS --db amazondb --collection review_collection --file /mnt/temp.json
import_end=$(date +%s.%N)
runtime=$((import_end-import_start))
echo "import time=$runtime"
