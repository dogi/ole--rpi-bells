#!/bin/bash

#variables
name='branch'
communityname='new.local'
communityport='5984'

#for win
#community='192.168.0.99:5984'
community="`getent hosts $communityname | awk '{ print $1 }'`:$communityport"

# load local settings from branch.config file
if [[ -r ./branch.config ]] ; then
    source ./branch.config
fi

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

wget http://ftp.debian.org/debian/pool/main/j/jq/jq_1.4-1~bpo70+1_armhf.deb
dpkg -i jq_1.4-1~bpo70+1_armhf.deb

# configurations database
curl -H 'Content-Type: application/json' -X POST http://127.0.0.1:5984/_replicate -d ' {"source": "http://'$community'/configurations", "target": "http://127.0.0.1:5984/configurations", "create_target": true} '
conf=`curl -X GET http://127.0.0.1:5984/configurations/_all_docs | sed '1d;$ d' | jq .id | tr -d '\"'`
doc=`curl -X GET 'http://127.0.0.1:5984/configurations/'$conf | jq '.nationName=""' | jq '.nationUrl=""' | jq '.subType = "branch"' | jq 'with_entries(select(.key != "_id"))'`
curl -X PUT 'http://127.0.0.1:5984/configurations/'$conf -d "$doc"

# branch
replicate activitylog
replicate apps
replicate assignmentpaper
replicate assignments
replicate calendar
replicate collectionlist
replicate communities
replicate community
replicate courseschedule
replicate coursestep
replicate feedback
replicate groups
replicate invitations
replicate languages
replicate mail
replicate meetups
replicate membercourseprogress
replicate nationreports
replicate publicationdistribution
replicate publications
replicate report
replicate requests
replicate resourcefrequency
replicate shelf
replicate usermeetups
replicate members
replicate communityreports
replicate resources

# write '/boot/autrun.sh'
echo '#!/bin/sh' > /boot/autorun.sh
echo '' >> /boot/autorun.sh
echo 'sleep 1' >> /boot/autorun.sh
echo 'docker start '$name >> /boot/autorun.sh

cd /usr/local/lib/node_modules/pirate-sh
npm update
pirateship expandfs
sync
sync
sync

reboot
