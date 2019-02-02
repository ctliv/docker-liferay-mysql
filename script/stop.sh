#!/bin/bash

#PID file
PIDFILE="$(dirname $0)/liferay_pid"

# LIFERAY_PID=$(cat $PIDFILE)
# kill -USR1 $LIFERAY_PID

#Renames file
mv "$PIDFILE" "${PIDFILE}.stopped" > /dev/null

#Stops catalina
/var/tomcat/bin/catalina.sh stop
