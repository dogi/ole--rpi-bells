#!/bin/bash

name='tigar2'
port='5984'
version='63'

# rename hostname of image to name
pirateship rename $name

# create couchdb docker container
docker run -d -p $port:5984 --name $name -v /srv/data/$name:/usr/local/var/lib/couchdb -v /srv/log/$name:/usr/local/var/log/couchdb dogi/rpi-couchdb

# download BeLL-Apps
mkdir -p /root/ole/$version
cd /root/ole/$version
wget https://github.com/open-learning-exchange/BeLL-Apps/archive/0.11.$version.zip
unzip *.zip
ln -s BeLL-Apps-* BeLL-Apps
cd BeLL-Apps
chmod +x node_modules/.bin/couchapp


# install community

# check if docker is running
while ! curl -X GET http://127.0.0.1:5984/_all_dbs ; do
  sleep 1
done

# create databases
curl -X PUT http://127.0.0.1:$port/activitylog
curl -X PUT http://127.0.0.1:$port/communities
curl -X PUT http://127.0.0.1:$port/feedback
curl -X PUT http://127.0.0.1:$port/membercourseprogress
curl -X PUT http://127.0.0.1:$port/requests
curl -X PUT http://127.0.0.1:$port/apps
curl -X PUT http://127.0.0.1:$port/community
curl -X PUT http://127.0.0.1:$port/groups
curl -X PUT http://127.0.0.1:$port/members
curl -X PUT http://127.0.0.1:$port/resourcefrequency
curl -X PUT http://127.0.0.1:$port/assignmentpaper
curl -X PUT http://127.0.0.1:$port/communityreports
curl -X PUT http://127.0.0.1:$port/invitations
curl -X PUT http://127.0.0.1:$port/nationreports
curl -X PUT http://127.0.0.1:$port/resources
curl -X PUT http://127.0.0.1:$port/assignments
curl -X PUT http://127.0.0.1:$port/configurations
curl -X PUT http://127.0.0.1:$port/languages
curl -X PUT http://127.0.0.1:$port/publicationdistribution
curl -X PUT http://127.0.0.1:$port/shelf
curl -X PUT http://127.0.0.1:$port/calendar
curl -X PUT http://127.0.0.1:$port/courseschedule
curl -X PUT http://127.0.0.1:$port/mail
curl -X PUT http://127.0.0.1:$port/publications
curl -X PUT http://127.0.0.1:$port/usermeetups
curl -X PUT http://127.0.0.1:$port/collectionlist
curl -X PUT http://127.0.0.1:$port/coursestep
curl -X PUT http://127.0.0.1:$port/meetups
curl -X PUT http://127.0.0.1:$port/report

## add bare minimal required data to couchdb for launching bell-apps smoothly
curl -d @init_docs/languages.txt -H "Content-Type: application/json" -X POST http://127.0.0.1:$port/languages
#curl -d @init_docs/languages-Urdu.txt -H "Content-Type: application/json" -X POST http://127.0.0.1:$port/languages
#curl -d @init_docs/languages-Arabic.txt -H "Content-Type: application/json" -X POST http://127.0.0.1:$port/languages
curl -d @init_docs/ConfigurationsDoc-Community.txt -H "Content-Type: application/json" -X POST http://127.0.0.1:$port/configurations
curl -d @init_docs/admin.txt -H "Content-Type: application/json" -X POST http://127.0.0.1:$port/members

## push design docs into couchdb
node_modules/.bin/couchapp push databases/activitylog.js http://127.0.0.1:$port/activitylog
node_modules/.bin/couchapp push databases/feedback.js http://127.0.0.1:$port/feedback
node_modules/.bin/couchapp push databases/membercourseprogress.js http://127.0.0.1:$port/membercourseprogress
node_modules/.bin/couchapp push databases/requests.js http://127.0.0.1:$port/requests
node_modules/.bin/couchapp push databases/apps.js http://127.0.0.1:$port/apps
node_modules/.bin/couchapp push databases/community.js http://127.0.0.1:$port/community
node_modules/.bin/couchapp push databases/groups.js http://127.0.0.1:$port/groups
node_modules/.bin/couchapp push databases/members.js http://127.0.0.1:$port/members
node_modules/.bin/couchapp push databases/resourcefrequency.js http://127.0.0.1:$port/resourcefrequency
node_modules/.bin/couchapp push databases/assignmentpaper.js http://127.0.0.1:$port/assignmentpaper
node_modules/.bin/couchapp push databases/communityreports.js http://127.0.0.1:$port/communityreports
node_modules/.bin/couchapp push databases/invitations.js http://127.0.0.1:$port/invitations
node_modules/.bin/couchapp push databases/nationreports.js http://127.0.0.1:$port/nationreports
node_modules/.bin/couchapp push databases/resources.js http://127.0.0.1:$port/resources
node_modules/.bin/couchapp push databases/assignments.js http://127.0.0.1:$port/assignments
node_modules/.bin/couchapp push databases/publicationdistribution.js http://127.0.0.1:$port/publicationdistribution
node_modules/.bin/couchapp push databases/shelf.js http://127.0.0.1:$port/shelf
node_modules/.bin/couchapp push databases/calendar.js http://127.0.0.1:$port/calendar
node_modules/.bin/couchapp push databases/courseschedule.js http://127.0.0.1:$port/courseschedule
node_modules/.bin/couchapp push databases/mail.js http://127.0.0.1:$port/mail
node_modules/.bin/couchapp push databases/publications.js http://127.0.0.1:$port/publications
node_modules/.bin/couchapp push databases/usermeetups.js http://127.0.0.1:$port/usermeetups
node_modules/.bin/couchapp push databases/collectionlist.js http://127.0.0.1:$port/collectionlist
node_modules/.bin/couchapp push databases/coursestep.js http://127.0.0.1:$port/coursestep
node_modules/.bin/couchapp push databases/meetups.js http://127.0.0.1:$port/meetups


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
