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
`$network`

# repository
if [[ ! -d $repository ]] ; then
  git clone 'https://github.com/dogi/'$repository'.git'
  cd $repository
else
  cd $repository
  git pull
fi

# newer autorun.sh?
if [ !(diff $directory/autorun.sh ../autorun.sh) ] ; then
  cp $directory/autorun.sh ../autorun.sh
fi

# wget qa content
cd ..
wget -c -r -l 1 -nc -np -A "*.couch" -e robots=off http://download.ole.org/.qa/.content/


# start script
`$respository/$directory/$script`
