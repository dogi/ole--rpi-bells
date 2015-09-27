#!/bin/bash

#variables
name='branch'
community='new.local:5984'

# rename hostname of image to name
pirateship rename $name

# template for continuous replication for databases
function replicate {
  curl -H 'Content-Type: application/json' -X POST http://127.0.0.1:5984/_replicate -d ' {"source": "http://$community/$1", "target": "http://127.0.0.1:5984/$1", "create_target": true, "continuous": true} '
  curl -H 'Content-Type: application/json' -X POST http://127.0.0.1:5984/_replicate -d ' {"source": "http://127.0.0.1:5984/$1", "target": "http://$community/$1", "continuous": true} '
  #curl -X GET http://$community/$1/_security | xargs curl -H 'Content-Type: application/json' -X PUT http://127.0.0.1:5984/$1/_security -d {}
}

# create couchdb docker container
docker run -d -p 5984:5984 --name $name -v /srv/data/$name:/usr/local/var/lib/couchdb -v /srv/log/$name:/usr/local/var/log/couchdb dogi/rpi-couchdb

#branch
#loop over all databases with function replicate
for database in `curl -X GET http://$community/_all_dbs | tr -d '[\[\"\]]' | tr , '\n' | sed '/^_/ d'`
do
  echo "d = $database"
  #replicate $database
done

reboot
