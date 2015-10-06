#!/bin/bash

# default settings
update=true
repository='ole--rpi-bells'
network='pirateship ethernet 204.9.221.79 255.255.255.128 204.9.221.1 "204.9.221.30 204.9.223.18 204.9.223.19"'
directory='qa'
script='2nations-autrunonce.sh'

# load local settings from qa.config file
if [[ -r ./qa.config ]] ; then
    source ./qa.config
fi

# set network
`Snetwork`

# repository
if [[ ! -d $repository ]] ; then
  git clone 'https://github.com/dogi/'$repository'.git'
  cd $repository
else
  cd $repository
  git pull
fi

# cp new autorun.sh over myself

# download qa content or check by sha1 if there is newer

# start one of the 3 scripts
