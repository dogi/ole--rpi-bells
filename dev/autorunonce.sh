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

# set password
if [[ $password != "" ]] ; then
  pass $password
fi

pirateship ethernet 204.9.221.59 255.255.255.128 204.9.221.1 "204.9.221.30 204.9.223.18 204.9.223.19"
