#!/bin/bash

#variables
name='branch'
communityname='new.local'
communityport='5984'

community="`getent hosts $communityname | awk '{ print $1 }'`:$communityport"

# rename hostname of image to name
pirateship rename $name

# template for continuous replication for databases
function replicate {
  curl -H 'Content-Type: application/json' -X POST http://127.0.0.1:5984/_replicator -d ' {"source": "http://'$community'/'$1'", "target": "http://127.0.0.1:5984/'$1'", "create_target": true, "continuous": true} '
  curl -H 'Content-Type: application/json' -X POST http://127.0.0.1:5984/_replicator -d ' {"source": "http://127.0.0.1:5984/'$1'", "target": "http://'$community'/'$1'", "continuous": true} '
  #curl -X GET http://$community/$1/_security | xargs curl -H 'Content-Type: application/json' -X PUT http://127.0.0.1:5984/$1/_security -d {}
}

# create couchdb docker container
docker run -d -p 5984:5984 --name $name -v /srv/data/$name:/usr/local/var/lib/couchdb -v /srv/log/$name:/usr/local/var/log/couchdb dogi/rpi-couchdb
sleep 20

# branch
# loop over all databases with function replicate
for database in `curl -X GET http://$community/_all_dbs | tr -d '[\[\"\]]' | tr , '\n' | sed '/^_/ d'`
do
  replicate $database
done

# write '/boot/autrun.sh'
echo '#!/bin/sh' > /boot/autorun.sh
echo '' >> /boot/autorun.sh
echo 'sleep 1' >> /boot/autorun.sh
echo 'docker start '$name >> /boot/autorun.sh

sync
sync
sync

reboot
