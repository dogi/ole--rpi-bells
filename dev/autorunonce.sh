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
