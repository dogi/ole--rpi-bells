#!/bin/bash

# rename hostname from raspberrypi to qa
pirateship rename qa

# configure static global valid ip address
pirateship ethernet 204.9.221.79 255.255.255.128 204.9.221.1 "204.9.221.30 204.9.223.18 204.9.223.19"
sleep 10

# template for nation install
function nation {
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

  # create install_linux
  echo "node_modules/.bin/couchapp push \$1 \$2" > pushDocToDb.sh
  chmod +x node_modules/.bin/couchapp pushDocToDb.sh
  cp install_windows install_linux
  sed -i "s/pushDocToDb.bat/.\/pushDocToDb.sh/" install_linux
  sed -i 's#databases\\\\#databases/#' install_linux

  # install nation
  node install_linux http://127.0.0.1:$2


  # overwrite some .couch with qa-content
  docker stop $1
  wget http://download.ole.org/.qa/content/collectionlist.couch -O /srv/data/$1/collectionlist.couch
  wget http://download.ole.org/.qa/content/coursestep.couch -O /srv/data/$1/coursestep.couch
  wget http://download.ole.org/.qa/content/groups.couch -O /srv/data/$1/groups.couch
  wget http://download.ole.org/.qa/content/publications.couch -O /srv/data/$1/publications.couch
  wget http://download.ole.org/.qa/content/resources.couch -O /srv/data/$1/resources.couch
  docker start $1

  node_modules/.bin/couchapp push databases/groups.js http://127.0.0.1:$2/groups
  node_modules/.bin/couchapp push databases/resources.js http://127.0.0.1:$2/resources
  node_modules/.bin/couchapp push databases/publications.js http://127.0.0.1:$2/publications
  node_modules/.bin/couchapp push databases/collectionlist.js http://127.0.0.1:$2/collectionlist
  node_modules/.bin/couchapp push databases/coursestep.js http://127.0.0.1:$2/coursestep

  # set configs
  curl -X PUT 'http://127.0.0.1:'$2'/_config/httpd/allow_jsonp' -d '"true"'
  #curl -X PUT 'http://127.0.0.1:'$2'/_config/httpd/enable_cors' -d '"true"'
  #curl -X PUT 'http://127.0.0.1:'$2'/_config/cors/origins' -d '"*"'
  curl -X PUT 'http://127.0.0.1:'$2'/_config/admins/nation' -d '"oleoleole"'

  # add to '/boot/autorun.sh'
  echo 'sleep 1' >> /boot/autorun.sh
  echo 'docker start '$1 >> /boot/autorun.sh

  # add to proxy
  echo '"'$1'.qa.ole.org": "http://'$1'.qa.ole.org:'$2'/apps/_design/bell/MyApp/index.html",' >> /root/ole/server.temp
  echo '"'$3'.qa.ole.org": "http://'$3'.qa.ole.org:'$2'/apps/_design/bell/MyApp/index.html",' >> /root/ole/server.temp

}

# write '/boot/autrun.sh'
echo '#!/bin/sh' > /boot/autorun.sh
echo '' >> /boot/autorun.sh



# install an old and a new nation
nation old 5984 52
nation new 5985 60



# write proxy
echo '#!/usr/bin/node' > /root/ole/server.js
echo "var express = require('express')" >> /root/ole/server.js
echo 'var PortJack = express()' >> /root/ole/server.js
echo 'PortJack.get(/^(.+)$/, function(req, res) {' >> /root/ole/server.js
echo 'var options = {' >> /root/ole/server.js
cat /root/ole/server.temp >> /root/ole/server.js
echo '"qa.ole.org": "http://ole.org/our-team/"' >> /root/ole/server.js
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
npm -g install express

# add to '/boot/autorun.sh'
echo '' >> /boot/autorun.sh
echo '/root/ole/server.js' >> /boot/autorun.sh

sync
sync
sync

reboot