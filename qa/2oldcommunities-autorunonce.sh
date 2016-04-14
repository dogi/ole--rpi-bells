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
  wget https://github.com/open-learning-exchange/BeLL-Apps/archive/$3.zip
  unzip *.zip
  ln -s BeLL-Apps-* BeLL-Apps
  cd BeLL-Apps
  chmod +x node_modules/.bin/couchapp
  sed -i 's/TestCommunity/'$1$name'/' init_docs/ConfigurationsDoc-Community.txt
  sed -i 's/communitybell/'$1$name'/' init_docs/ConfigurationsDoc-Community.txt
  sed -i 's/openbell.ole.org:5984/'$name'.qa.ole.org:'$port'/' init_docs/ConfigurationsDoc-Community.txt
  sed -i 's/openbell/nation/' init_docs/ConfigurationsDoc-Community.txt


  # install community

  ## create databases & push design docs into them
  for database in databases/*.js; do
    curl -X PUT http://127.0.0.1:$2/${database:10:-3}
    ## do in all except communities languages configurations
    case ${database:10:-3} in
      "communities" | "languages" | "configurations" ) ;;
      * ) node_modules/.bin/couchapp push $database http://127.0.0.1:$2/${database:10:-3} ;;
    esac
  done

  ## add bare minimal required data to couchdb for launching bell-apps smoothly
  for filename in init_docs/languages/*.txt; do
    curl -d @$filename -H "Content-Type: application/json" -X POST http://127.0.0.1:$2/languages;
  done
  curl -d @init_docs/ConfigurationsDoc-Community.txt -H "Content-Type: application/json" -X POST http://127.0.0.1:$2/configurations
  curl -d @init_docs/admin.txt -H "Content-Type: application/json" -X POST http://127.0.0.1:$2/members

  # add users
  curl -X POST -H "Content-Type: application/json" 'http://127.0.0.1:'$2'/members' --data '{"kind":"Member","roles":["Learner"],"firstName":"a","lastName":"a","middleNames":"a","login":"a","password":"a","phone":"a","email":"a@a","language":"","BirthDate":"2010-10-15T04:00:00.000Z","visits":0,"Gender":"Male","levels":"1","status":"active","yearsOfTeaching":null,"teachingCredentials":null,"subjectSpecialization":null,"forGrades":null,"community":"newnew","region":"","nation":"nation"}'
  curl -X POST -H "Content-Type: application/json" 'http://127.0.0.1:'$2'/members' --data '{"kind":"Member","roles":["Learner"],"firstName":"b","lastName":"b","middleNames":"b","login":"b","password":"b","phone":"b","email":"b@b","language":"","BirthDate":"2010-10-15T04:00:00.000Z","visits":0,"Gender":"Female","levels":"1","status":"active","yearsOfTeaching":null,"teachingCredentials":null,"subjectSpecialization":null,"forGrades":null,"community":"newnew","region":"","nation":"nation"}'
  curl -X POST -H "Content-Type: application/json" 'http://127.0.0.1:'$2'/members' --data '{"kind":"Member","roles":["Learner"],"firstName":"c","lastName":"c","middleNames":"c","login":"c","password":"c","phone":"c","email":"c@c","language":"","BirthDate":"2005-10-15T04:00:00.000Z","visits":0,"Gender":"Male","levels":"4","status":"active","yearsOfTeaching":null,"teachingCredentials":null,"subjectSpecialization":null,"forGrades":null,"community":"newnew","region":"","nation":"nation"}'
  curl -X POST -H "Content-Type: application/json" 'http://127.0.0.1:'$2'/members' --data '{"kind":"Member","roles":["Learner"],"firstName":"d","lastName":"d","middleNames":"d","login":"d","password":"d","phone":"d","email":"d@d","language":"","BirthDate":"2005-10-15T04:00:00.000Z","visits":0,"Gender":"Female","levels":"4","status":"active","yearsOfTeaching":null,"teachingCredentials":null,"subjectSpecialization":null,"forGrades":null,"community":"newnew","region":"","nation":"nation"}'
  curl -X POST -H "Content-Type: application/json" 'http://127.0.0.1:'$2'/members' --data '{"kind":"Member","roles":["Learner"],"firstName":"e","lastName":"e","middleNames":"e","login":"e","password":"e","phone":"e","email":"e@e","language":"","BirthDate":"2000-10-15T04:00:00.000Z","visits":0,"Gender":"Male","levels":"7","status":"active","yearsOfTeaching":null,"teachingCredentials":null,"subjectSpecialization":null,"forGrades":null,"community":"newnew","region":"","nation":"nation"}'
  curl -X POST -H "Content-Type: application/json" 'http://127.0.0.1:'$2'/members' --data '{"kind":"Member","roles":["Learner"],"firstName":"f","lastName":"f","middleNames":"f","login":"f","password":"f","phone":"f","email":"f@f","language":"","BirthDate":"2000-10-15T04:00:00.000Z","visits":0,"Gender":"Female","levels":"7","status":"active","yearsOfTeaching":null,"teachingCredentials":null,"subjectSpecialization":null,"forGrades":null,"community":"newnew","region":"","nation":"nation"}'
  curl -X POST -H "Content-Type: application/json" 'http://127.0.0.1:'$2'/members' --data '{"kind":"Member","roles":["Learner"],"firstName":"g","lastName":"g","middleNames":"g","login":"g","password":"g","phone":"g","email":"g@g","language":"","BirthDate":"1995-10-15T04:00:00.000Z","visits":0,"Gender":"Male","levels":"10","status":"active","yearsOfTeaching":null,"teachingCredentials":null,"subjectSpecialization":null,"forGrades":null,"community":"newnew","region":"","nation":"nation"}'
  curl -X POST -H "Content-Type: application/json" 'http://127.0.0.1:'$2'/members' --data '{"kind":"Member","roles":["Learner"],"firstName":"h","lastName":"h","middleNames":"h","login":"h","password":"h","phone":"h","email":"h@h","language":"","BirthDate":"1995-10-15T04:00:00.000Z","visits":0,"Gender":"Female","levels":"10","status":"active","yearsOfTeaching":null,"teachingCredentials":null,"subjectSpecialization":null,"forGrades":null,"community":"newnew","region":"","nation":"nation"}'
  curl -X POST -H "Content-Type: application/json" 'http://127.0.0.1:'$2'/members' --data '{"kind":"Member","roles":["Learner"],"firstName":"i","lastName":"i","middleNames":"i","login":"i","password":"i","phone":"i","email":"i@i","language":"","BirthDate":"1990-10-15T04:00:00.000Z","visits":0,"Gender":"Male","levels":"Higher","status":"active","yearsOfTeaching":null,"teachingCredentials":null,"subjectSpecialization":null,"forGrades":null,"community":"newnew","region":"","nation":"nation"}'
  curl -X POST -H "Content-Type: application/json" 'http://127.0.0.1:'$2'/members' --data '{"kind":"Member","roles":["Learner"],"firstName":"j","lastName":"j","middleNames":"j","login":"j","password":"j","phone":"j","email":"j@j","language":"","BirthDate":"1990-10-15T04:00:00.000Z","visits":0,"Gender":"Female","levels":"Higher","status":"active","yearsOfTeaching":null,"teachingCredentials":null,"subjectSpecialization":null,"forGrades":null,"community":"newnew","region":"","nation":"nation"}'

  # add to '/boot/autorun.sh'
  echo 'sleep 1' >> /boot/autorun.sh
  echo 'docker start '$1 >> /boot/autorun.sh

  echo '"<a href=http://'$name'.local:'$2'/apps/_design/bell/MyApp/index.html>http://'$name'.local:'$2'/apps/_design/bell/MyApp/index.html</a> <a href=http://'$name'.local:'$2'/_utils>http://'$name'.local:'$2'/_utils</a><br/>"+' >> /root/ole/server.temp

}

# write '/boot/autrun.sh'
echo '#!/bin/sh' > /boot/autorun.sh
echo '' >> /boot/autorun.sh

community old 5984 0.11.111
community new 5985 0.12.5

# write simple webpage with links
echo '#!/usr/bin/env node' > /root/ole/server.js
echo '' >> /root/ole/server.js
echo "var express = require('express')" >> /root/ole/server.js
echo 'var app = express()' >> /root/ole/server.js
echo '' >> /root/ole/server.js
echo "app.get('/', function(req, res) {" >> /root/ole/server.js
echo '    res.send("<html>"+' >> /root/ole/server.js
cat /root/ole/server.temp >> /root/ole/server.js
echo '"</html>");' >> /root/ole/server.js
echo '});' >> /root/ole/server.js
echo '' >> /root/ole/server.js
echo 'app.listen(80);' >> /root/ole/server.js
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
