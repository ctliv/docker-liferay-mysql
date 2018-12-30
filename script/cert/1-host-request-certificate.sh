#!/bin/bash

scriptreal=$(realpath "$0")
scriptabs=$(dirname "$scriptreal")
scriptdir=$(dirname "$0")
scriptname=$(basename "$0")
scriptext="${scriptname##*.}"

showhelp () {
	echo
	echo "USAGE: $scriptname hostname"
	echo
	exit 1
}

if [ $# -ne 1 ]; then
	echo "Illegal number of parameters"
    showhelp
fi

host="$1"

#Install certbot (from https://certbot.eff.org/lets-encrypt/ubuntubionic-other)
sudo apt-get update
sudo apt-get install software-properties-common
sudo add-apt-repository universe
sudo add-apt-repository ppa:certbot/certbot
sudo apt-get update
sudo apt-get install certbot 

#Request certificate (containers must be stopped, as --standalone mode starts a temporary server on port 80)
sudo certbot certonly --standalone -d $1

#Enables container lep-as to read certificate
sudo chmod a+rwx -R /etc/letsencrypt

#Add the following among shared volumes in docker-compose for service "liferay" (container name: "lep-as")
#      - /etc/letsencrypt:/etc/letsencrypt
