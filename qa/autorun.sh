#!/bin/bash

# default settings
update=true
repository='ole--rpi-bells'
network='pirateship ethernet ...'
script='qa/2nations-autrunonce.sh'

# load local settings from qa.config file
if [[ -r ./qa.config ]] ; then
    source ./qa.config
fi

# set rpi network
#`Snetwork`

# git pull to get newest code, if not here create
# cp new autorun.sh over myself

# download qa content or check by sha1 if there is newer

# start one of the 3 scripts
