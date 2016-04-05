#!/bin/bash

showhelp () {
	echo "USAGE: lep-boot.sh [options]"
	echo "OPTIONS:"
	echo "    -d          Startup DB (default: false, default image: \"mysql:5.7\")"
	echo "    -a          Startup AS (default: false, default image: \"ctliv/liferay:7.0\")"
	echo "    -n          Avoid AS startup wizard (default: false)"
	echo "    -h <host>   Public hostname of the VM (default: \"lep-dev.dynu.com\")"
	echo "    -s          Stops (if running) and remove container(s)"
	echo
	echo "NOTE:"
	echo "    At least -d or -a must be specified"
	echo
	exit
}

OPTIND=1
db=0
as=0
hostname="lep-dev.dynu.com"
nowizard=0
sc=0

while getopts "dansh:" opt; do
	case "$opt" in
	d)	db=1
		;;
	a)	as=1
		;;
	n)	nowizard=1
		;;
	s)	sc=1
		;;
	h)	hostname=$OPTARG
	esac
done

shift $((OPTIND-1))

[ "$1" = "--" ] && shift

if [ $db -eq 0 ] && [ $as -eq 0 ]; then
	showhelp
fi

if [ $sc -eq 1 ]; then
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
	"$(dirname $(readlink -f $0))/run-db.sh"
fi

if [ $as -eq 1 ]; then
	"$(dirname $(readlink -f $0))/run-as.sh" -e VM_HOST=${hostname} -e LIFERAY_NOWIZARD=${nowizard}
fi

