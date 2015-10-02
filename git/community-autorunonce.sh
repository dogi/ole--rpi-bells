#!/bin/sh

# rename hostname of image to bell
pirateship rename git

# create couchdb docker container
docker run -d -p 5984:5984 --name bell -v /srv/data/bell:/usr/local/var/lib/couchdb -v /srv/log/bell:/usr/local/var/log/couchdb dogi/rpi-couchdb

#http://git.local:5984/apps/_design/bell/MyApp/index.html

BRANCH=dev

# download BeLL-Apps
mkdir -p /root/ole/$BRANCH
cd /root/ole/$BRANCH
git clone -b $BRANCH https://github.com/open-learning-exchange/BeLL-Apps.git
cd BeLL-Apps
chmod +x node_modules/.bin/couchapp

# install community

## create databases
curl -X PUT http://localhost:5984/activitylog
curl -X PUT http://localhost:5984/communities
curl -X PUT http://localhost:5984/feedback
curl -X PUT http://localhost:5984/membercourseprogress
curl -X PUT http://localhost:5984/requests
curl -X PUT http://localhost:5984/apps
curl -X PUT http://localhost:5984/community
curl -X PUT http://localhost:5984/groups
curl -X PUT http://localhost:5984/members
curl -X PUT http://localhost:5984/resourcefrequency
curl -X PUT http://localhost:5984/assignmentpaper
curl -X PUT http://localhost:5984/communityreports
curl -X PUT http://localhost:5984/invitations
curl -X PUT http://localhost:5984/nationreports
curl -X PUT http://localhost:5984/resources
curl -X PUT http://localhost:5984/assignments
curl -X PUT http://localhost:5984/configurations
curl -X PUT http://localhost:5984/languages
curl -X PUT http://localhost:5984/publicationdistribution
curl -X PUT http://localhost:5984/shelf
curl -X PUT http://localhost:5984/calendar
curl -X PUT http://localhost:5984/courseschedule
curl -X PUT http://localhost:5984/mail
curl -X PUT http://localhost:5984/publications
curl -X PUT http://localhost:5984/usermeetups
curl -X PUT http://localhost:5984/collectionlist
curl -X PUT http://localhost:5984/coursestep
curl -X PUT http://localhost:5984/meetups
curl -X PUT http://localhost:5984/report

## add bare minimal required data to couchdb for launching bell-apps smoothly
curl -d @init_docs/languages.txt -H "Content-Type: application/json" -X POST http://localhost:5984/languages
curl -d @init_docs/ConfigurationsDoc-Community.txt -H "Content-Type: application/json" -X POST http://localhost:5984/configurations
curl -d @init_docs/admin.txt -H "Content-Type: application/json" -X POST http://localhost:5984/members

## push design docs into couchdb
node_modules/.bin/couchapp push databases/activitylog.js http://localhost:5984/activitylog
node_modules/.bin/couchapp push databases/feedback.js http://localhost:5984/feedback
node_modules/.bin/couchapp push databases/membercourseprogress.js http://localhost:5984/membercourseprogress
node_modules/.bin/couchapp push databases/requests.js http://localhost:5984/requests
node_modules/.bin/couchapp push databases/apps.js http://localhost:5984/apps
node_modules/.bin/couchapp push databases/community.js http://localhost:5984/community
node_modules/.bin/couchapp push databases/groups.js http://localhost:5984/groups
node_modules/.bin/couchapp push databases/members.js http://localhost:5984/members
node_modules/.bin/couchapp push databases/resourcefrequency.js http://localhost:5984/resourcefrequency
node_modules/.bin/couchapp push databases/assignmentpaper.js http://localhost:5984/assignmentpaper
node_modules/.bin/couchapp push databases/communityreports.js http://localhost:5984/communityreports
node_modules/.bin/couchapp push databases/invitations.js http://localhost:5984/invitations
node_modules/.bin/couchapp push databases/nationreports.js http://localhost:5984/nationreports
node_modules/.bin/couchapp push databases/resources.js http://localhost:5984/resources
node_modules/.bin/couchapp push databases/assignments.js http://localhost:5984/assignments
node_modules/.bin/couchapp push databases/publicationdistribution.js http://localhost:5984/publicationdistribution
node_modules/.bin/couchapp push databases/shelf.js http://localhost:5984/shelf
node_modules/.bin/couchapp push databases/calendar.js http://localhost:5984/calendar
node_modules/.bin/couchapp push databases/courseschedule.js http://localhost:5984/courseschedule
node_modules/.bin/couchapp push databases/mail.js http://localhost:5984/mail
node_modules/.bin/couchapp push databases/publications.js http://localhost:5984/publications
node_modules/.bin/couchapp push databases/usermeetups.js http://localhost:5984/usermeetups
node_modules/.bin/couchapp push databases/collectionlist.js http://localhost:5984/collectionlist
node_modules/.bin/couchapp push databases/coursestep.js http://localhost:5984/coursestep
node_modules/.bin/couchapp push databases/meetups.js http://localhost:5984/meetups

echo '#!/bin/sh' > /boot/autorun.sh
echo '' >> /boot/autorun.sh
echo 'sleep 1' >> /boot/autorun.sh
echo 'docker start bell' >> /boot/autorun.sh
  
reboot
