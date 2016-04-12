#!/bin/bash

# default settings
#update=true
repository='ole--rpi-bells'
user='dogi'
directory='qa'
network=''
password=''
script='2nations-autorunonce.sh'

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

if [[ ! -e /boot/autorun.sh ]] ; then
  # set password
  if [[ $password != "" ]] ; then
    pass $password
  fi

  # set network
  if [[ $network != "" ]] ; then
    $network
  fi

  # check if still/again online
  while ! curl -X GET http://github.com ; do
    sleep 1
  done

  # repository
  if [[ ! -d $repository ]] ; then
    git clone 'https://github.com/'$user'/'$repository'.git'
  fi
  cd $repository
  git pull

  # newer autorun.sh?
  if ! diff $directory/autorun.sh ../autorun.sh ; then
    cp $directory/autorun.sh ../autorun.sh
  fi

  # wget qa content
  cd ..
  wget -c -r -l 1 -nc -np -A "*.couch" -e robots=off http://download.ole.org/.qa/.content/

  sync
  sync
  sync

  # start script
  $repository/$directory/$script
fi
/boot/autorun.sh
