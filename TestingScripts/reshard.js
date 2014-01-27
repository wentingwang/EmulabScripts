use testdb
people = ["Marc", "Bill", "George", "Eliot", "Matt", "Trey", "Tracy", "Greg", "Steve", "Kristina", "Katie", "Jeff"];
for(var i=0; i<10000; i++){

name = people[Math.floor(Math.random()*people.length)];

user_id = i;

boolean = [true, false][Math.floor(Math.random()*2)];

added_at = new Date();

number = 10000 - i;

db.test_collection.save({"name":name, "user_id":user_id, "boolean": boolean, "added_at":added_at, "number":number });

}

sh.enableSharding("testdb")
db.test_collection.ensureIndex({user_id:1})
db.test_collection.ensureIndex({number:1}) 
sh.shardCollection("testdb.test_collection",{user_id:1})
sh.reShardCollection("testdb.test_collection",{number:1})