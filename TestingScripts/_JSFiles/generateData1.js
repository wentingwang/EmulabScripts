use amazondb;
people = ["Marc", "Bill", "George", "Eliot", "Matt", "Trey", "Tracy", "Greg", "Steve", "Kristina", "Katie", "Jeff"];

totlaCount = 100000;
numRow = 100000;

for(var i=0; i<numRow; i++){

name = people[Math.floor(Math.random()*people.length)];
user_id = Math.floor(Math.random()*totlaCount);
boolean = [true, false][Math.floor(Math.random()*2)];
added_at = new Date();
number = Math.floor(Math.random()*totlaCount);
db.review_collection.save({"name":name, "user_id":user_id, "boolean":boolean, "added_at":added_at, "number":number });
}

sh.enableSharding("amazondb")
db.review_collection.ensureIndex({user_id:1})
sh.shardCollection("amazondb.review_collection",{user_id:1})
