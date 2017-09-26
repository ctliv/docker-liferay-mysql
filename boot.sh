#!/bin/bash

DB_IMAGE="mysql:5.6"
AS_IMAGE="ctliv/liferay:7.0"

showhelp () {
	echo "USAGE: boot.sh [options]"
	echo "OPTIONS:"
	echo "    -d         Startup DB (image: \"${DB_IMAGE}\")"
	echo "    -a         Startup AS (image: \"${AS_IMAGE}\")"
	echo "    -n         Avoid AS startup wizard (default: false)"
	echo "    -h <host>  Public hostname of the VM (default: \"${host}\")"
	echo "    -c         Cleanup: stops (if running) and remove container(s)"
	echo "    -P         Production mode: debug ports are not exposed"
	echo
	echo "NOTE:"
	echo "    At least -d or -a must be specified"
	echo
	exit
}

OPTIND=1
db=0
as=0
host=$(wget http://ipinfo.io/ip -qO -)
nowizard=0
cleanup=0
debugports="-p 2222:22 -p 1099:1099 -p 8999:8999 -p 2525:2525"

while getopts "danch:" opt; do
	case "$opt" in
	d)	db=1
		;;
	a)	as=1
		;;
	n)	nowizard=1
		;;
	c)	cleanup=1
		;;
	P)	debugports=""
		;;
	h)	host=$OPTARG
	esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

if [ $db -eq 0 ] && [ $as -eq 0 ]; then
	showhelp
fi

#Default values
if [ "$host" == "" ]; then
	host="lep-dev.dynu.com"
fi

if [ $cleanup -eq 1 ]; then
	if [ $as -eq 1 ]; then
		docker stop lep-as
		docker rm lep-as
	fi
	if [ $db -eq 1 ]; then
		docker stop lep-db
		docker rm lep-db
	fi
fi

if [ $db -eq 1 ]; then
	docker run --name lep-db -p 3306:3306 -e MYSQL_ROOT_PASSWORD=adminpwd -e MYSQL_USER=lportal -e MYSQL_PASSWORD=lportal -e MYSQL_DATABASE=lportal -d ${DB_IMAGE} --character-set-server=utf8 --collation-server=utf8_unicode_ci
fi

if [ $as -eq 1 ]; then
	docker run --name lep-as -p 80:8080 -p 443:8443 ${debugports} --link lep-db -e LIFERAY_DEBUG=1 -v /$(dirname $(readlink -f $0))/deploy:/var/liferay/deploy -v /$(dirname $(readlink -f $0))/data:/opt/data -e VM_HOST=${host} -e LIFERAY_NOWIZARD=${nowizard} -d ${AS_IMAGE}
fi

