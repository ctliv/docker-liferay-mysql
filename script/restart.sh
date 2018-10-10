#!/bin/bash

#PID file
PIDFILE="$(dirname $0)/liferay_pid"

# LIFERAY_PID=$(cat $PIDFILE)
# kill -CONT $LIFERAY_PID

#Renames file
mv "${PIDFILE}.stopped" "$PIDFILE" > /dev/null

