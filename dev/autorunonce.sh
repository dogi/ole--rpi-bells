#!/bin/bash

pirateship rename dev

# default settings
password=''

function pass {
passwd pi << EOF
$1
$1
EOF
}

# load local settings from qa.config file
if [[ -r ./qa.config ]] ; then
    source ./qa.config
fi

# set password
if [[ $password != "" ]] ; then
  pass $password
fi

pirateship ethernet 204.9.221.59 255.255.255.128 204.9.221.1 "204.9.221.30 204.9.223.18 204.9.223.19"

sleep 20

# dev grunt
mkdir ole
cd ole/
wget https://github.com/open-learning-exchange/BeLL-Apps/archive/0.11.67.zip
unzip 0.11.67.zip 
ls -al
ln -s BeLL-Apps-* release
mkdir production
npm install -g grunt-cli
npm install grunt
npm install grunt-newer --save-dev
npm install grunt-contrib-uglify --save-dev
npm install grunt-contrib-concat --save-dev
wget https://raw.githubusercontent.com/open-learning-exchange/BeLL-Apps/grunt_uglify_and_concat/Gruntfile.js
#grunt
