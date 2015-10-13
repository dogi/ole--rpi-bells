#!/bin/bash

name='old'
port='5984'

# rename hostname of image to name
pirateship rename $name

# template for community install
function community {
  # s1 = name
  # s2 = port
  # s3 = version

  # create couchdb docker container
  docker run -d -p $2:5984 --name $1 -v /srv/data/$1:/usr/local/var/lib/couchdb -v /srv/log/$1:/usr/local/var/log/couchdb dogi/rpi-couchdb

  # download BeLL-Apps
  mkdir -p /root/ole/$3
  cd /root/ole/$3
  wget https://github.com/open-learning-exchange/BeLL-Apps/archive/0.11.$3.zip
  unzip *.zip
  ln -s BeLL-Apps-* BeLL-Apps
  cd BeLL-Apps
  chmod +x node_modules/.bin/couchapp
  sed -i 's/TestCommunity/'$1$name'/' init_docs/ConfigurationsDoc-Community.txt
  sed -i 's/communitybell/'$1$name'/' init_docs/ConfigurationsDoc-Community.txt
  sed -i 's/openbell.ole.org:5984/'$name'.qa.ole.org:'$port'/' init_docs/ConfigurationsDoc-Community.txt
  sed -i 's/openbell/nation/' init_docs/ConfigurationsDoc-Community.txt


  # install community

  ## create databases
  curl -X PUT http://127.0.0.1:$2/activitylog
  curl -X PUT http://127.0.0.1:$2/communities
  curl -X PUT http://127.0.0.1:$2/feedback
  curl -X PUT http://127.0.0.1:$2/membercourseprogress
  curl -X PUT http://127.0.0.1:$2/requests
  curl -X PUT http://127.0.0.1:$2/apps
  curl -X PUT http://127.0.0.1:$2/community
  curl -X PUT http://127.0.0.1:$2/groups
  curl -X PUT http://127.0.0.1:$2/members
  curl -X PUT http://127.0.0.1:$2/resourcefrequency
  curl -X PUT http://127.0.0.1:$2/assignmentpaper
  curl -X PUT http://127.0.0.1:$2/communityreports
  curl -X PUT http://127.0.0.1:$2/invitations
  curl -X PUT http://127.0.0.1:$2/nationreports
  curl -X PUT http://127.0.0.1:$2/resources
  curl -X PUT http://127.0.0.1:$2/assignments
  curl -X PUT http://127.0.0.1:$2/configurations
  curl -X PUT http://127.0.0.1:$2/languages
  curl -X PUT http://127.0.0.1:$2/publicationdistribution
  curl -X PUT http://127.0.0.1:$2/shelf
  curl -X PUT http://127.0.0.1:$2/calendar
  curl -X PUT http://127.0.0.1:$2/courseschedule
  curl -X PUT http://127.0.0.1:$2/mail
  curl -X PUT http://127.0.0.1:$2/publications
  curl -X PUT http://127.0.0.1:$2/usermeetups
  curl -X PUT http://127.0.0.1:$2/collectionlist
  curl -X PUT http://127.0.0.1:$2/coursestep
  curl -X PUT http://127.0.0.1:$2/meetups
  curl -X PUT http://127.0.0.1:$2/report

  ## add bare minimal required data to couchdb for launching bell-apps smoothly
  curl -d @init_docs/languages.txt -H "Content-Type: application/json" -X POST http://127.0.0.1:$2/languages
  curl -d @init_docs/ConfigurationsDoc-Community.txt -H "Content-Type: application/json" -X POST http://127.0.0.1:$2/configurations
  curl -d @init_docs/admin.txt -H "Content-Type: application/json" -X POST http://127.0.0.1:$2/members

  ## push design docs into couchdb
  node_modules/.bin/couchapp push databases/activitylog.js http://127.0.0.1:$2/activitylog
  node_modules/.bin/couchapp push databases/feedback.js http://127.0.0.1:$2/feedback
  node_modules/.bin/couchapp push databases/membercourseprogress.js http://127.0.0.1:$2/membercourseprogress
  node_modules/.bin/couchapp push databases/requests.js http://127.0.0.1:$2/requests
  node_modules/.bin/couchapp push databases/apps.js http://127.0.0.1:$2/apps
  node_modules/.bin/couchapp push databases/community.js http://127.0.0.1:$2/community
  node_modules/.bin/couchapp push databases/groups.js http://127.0.0.1:$2/groups
  node_modules/.bin/couchapp push databases/members.js http://127.0.0.1:$2/members
  node_modules/.bin/couchapp push databases/resourcefrequency.js http://127.0.0.1:$2/resourcefrequency
  node_modules/.bin/couchapp push databases/assignmentpaper.js http://127.0.0.1:$2/assignmentpaper
  node_modules/.bin/couchapp push databases/communityreports.js http://127.0.0.1:$2/communityreports
  node_modules/.bin/couchapp push databases/invitations.js http://127.0.0.1:$2/invitations
  node_modules/.bin/couchapp push databases/nationreports.js http://127.0.0.1:$2/nationreports
  node_modules/.bin/couchapp push databases/resources.js http://127.0.0.1:$2/resources
  node_modules/.bin/couchapp push databases/assignments.js http://127.0.0.1:$2/assignments
  node_modules/.bin/couchapp push databases/publicationdistribution.js http://127.0.0.1:$2/publicationdistribution
  node_modules/.bin/couchapp push databases/shelf.js http://127.0.0.1:$2/shelf
  node_modules/.bin/couchapp push databases/calendar.js http://127.0.0.1:$2/calendar
  node_modules/.bin/couchapp push databases/courseschedule.js http://127.0.0.1:$2/courseschedule
  node_modules/.bin/couchapp push databases/mail.js http://127.0.0.1:$2/mail
  node_modules/.bin/couchapp push databases/publications.js http://127.0.0.1:$2/publications
  node_modules/.bin/couchapp push databases/usermeetups.js http://127.0.0.1:$2/usermeetups
  node_modules/.bin/couchapp push databases/collectionlist.js http://127.0.0.1:$2/collectionlist
  node_modules/.bin/couchapp push databases/coursestep.js http://127.0.0.1:$2/coursestep
  node_modules/.bin/couchapp push databases/meetups.js http://127.0.0.1:$2/meetups

  # add to '/boot/autorun.sh'
  echo 'sleep 1' >> /boot/autorun.sh
  echo 'docker start '$1 >> /boot/autorun.sh

}

# write '/boot/autrun.sh'
echo '#!/bin/sh' > /boot/autorun.sh
echo '' >> /boot/autorun.sh

community old 5984 63
community new 5985 67
 
reboot
