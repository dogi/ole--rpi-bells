#!/bin/bash

#variables
name='branch'
community='new.local:5984'

# rename hostname of image to name
pirateship rename $name

# template for continuous replication for databases
function replicate {
#clone or create database
#replicate curl -H 'Content-Type: application/json' -X POST http://localhost:5984/_replicate -d ' {"source": "http://admin:admin_password@production:5984/foo", "target": "http://admin:admin_password@stage:5984/foo", "create_target": true, "continuous": true} '
#reverse replicate
#security: curl -X GET http://admin:admin_password@localhost:5984/foo/_security | xargs curl -H 'Content-Type: application/json' -X PUT http://admin:admin_password@localhost:5984/foo/_security -d {}
}

# create couchdb docker container
#docker run -d -p $2:5984 --name $1 -v /srv/data/$1:/usr/local/var/lib/couchdb -v /srv/log/$1:/usr/local/var/log/couchdb dogi/rpi-couchdb

#branch
#loop over all databases with function replicate
#curl -X GET http://$community/_all_dbs

reboot
