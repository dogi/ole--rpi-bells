#!/bin/bash

#variables
name='branch'
ip='192.168.0.99'
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

while ! curl -X GET http://127.0.0.1:5984/_all_dbs ; do
  sleep 1
done

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

# expand filesystem
cd /usr/local/lib/
npm update
pirateship expandfs

# redirect to bell
mkdir -p /root/ole
echo '#!/usr/bin/env node' > /root/ole/server.js
echo '' >> /root/ole/server.js
echo "var express = require('express')" >> /root/ole/server.js
echo 'var PortJack = express()' >> /root/ole/server.js
echo 'PortJack.get(/^(.+)$/, function(req, res) {' >> /root/ole/server.js
echo 'var options = {' >> /root/ole/server.js
echo '"'$name'.local": "http://'$name'.local:5984/apps/_design/bell/MyApp/index.html",' >> /root/ole/server.js
echo '"'$ip'": "http://'$ip':5984/apps/_design/bell/MyApp/index.html"' >> /root/ole/server.js
echo '}' >> /root/ole/server.js
echo 'if (options.hasOwnProperty(req.hostname)) {' >> /root/ole/server.js
echo "res.setHeader('Location', options[req.hostname])" >> /root/ole/server.js
echo '}' >> /root/ole/server.js
echo 'else {' >> /root/ole/server.js
echo "res.setHeader('Location', 'http://ole.org')" >> /root/ole/server.js
echo '}' >> /root/ole/server.js
echo 'res.statusCode = 302' >> /root/ole/server.js
echo 'res.end()' >> /root/ole/server.js
echo '})' >> /root/ole/server.js
echo 'PortJack.listen(80)' >> /root/ole/server.js
chmod +x /root/ole/server.js
cd /root/ole
npm install express

# add to '/boot/autorun.sh'
echo '' >> /boot/autorun.sh
echo 'node /root/ole/server.js' >> /boot/autorun.sh

sync
sync
sync

reboot
