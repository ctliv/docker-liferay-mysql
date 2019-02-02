#!/bin/bash

RUN_LOG=$(dirname $0)/run.log

echo "Executing run as user: $(whoami)" > $RUN_LOG
echo "Starting liferay in: /var/liferay" >> $RUN_LOG
echo "with portal-setup-wizard.properties:" >> $RUN_LOG
echo "####################################" >> $RUN_LOG
cat /var/liferay/portal-setup-wizard.properties >> $RUN_LOG
echo "####################################" >> $RUN_LOG

#Override LIFERAY_DEBUG from command line
if [ -n "$1" ]; then
	echo "Debug activated from command line" >> $RUN_LOG
	LIFERAY_DEBUG=1
fi

#Disables Liferay setup wizard if LIFERAY_NOWIZARD is set (useful to regenerate a new lep-as with an already existing lep-db)
if [ -n "$LIFERAY_NOWIZARD" ]; then 
	echo "Disabling Liferay wizard..." >> $RUN_LOG
	echo "setup.wizard.enabled=false" >> /var/liferay/portal-setup-wizard.properties
	#sed -i 's/\s*setup.wizard.enabled\s*=\s*true/setup.wizard.enabled=false/' /var/liferay/portal-setup-wizard.properties
fi

#Stops ssh daemon (if running)
service ssh stop

if [ -n "$LIFERAY_DEBUG" ]; then
	echo "Enabling debug services..." >> $RUN_LOG
	#Configure and launch ssh
	sed -i 's/#*\s*PermitRootLogin .*/PermitRootLogin yes/' /etc/ssh/sshd_config
	sed -i 's/#*\s*PubkeyAuthentication .*/PubkeyAuthentication no/' /etc/ssh/sshd_config
	# SSH login fix. Otherwise user is kicked off after login
	sed 's@session\s*required\s*pam_loginuid.so@session optional pam_loginuid.so@g' -i /etc/pam.d/sshd	
	#Start ssh daemon
	service ssh start

	#Define default host for JMX debugging 
	if [ -z "$VM_HOST" ]; then 
		VM_HOST=localhost
	fi
	echo "Setting RMI server hostname to: ${VM_HOST}" >> $RUN_LOG

	## (disabled) Runs jstatd endpoint on port 1098 for remote JVM monitoring (use SSH tunnel)
	## Creates policy file
	#policy=$(dirname $0)/jstatd.all.policy
	#echo "grant codebase \"file:${JAVA_HOME}/lib/tools.jar\" {" > $policy
	#echo "  permission java.security.AllPermission;" >> $policy
	#echo "};" >> $policy	
	## Launch jstatd
	#jstatd -p 1098 -J-Djava.security.policy=$(dirname $0)/jstatd.all.policy -J-Djava.net.preferIPv4Stack=true -J-Djava.rmi.server.hostname=${VM_HOST} &

	#Enables JMX endpoint (on port 1099)
	OPTS="-Dcom.sun.management.jmxremote=true"
	OPTS="$OPTS -Dcom.sun.management.jmxremote.ssl=false"
	OPTS="$OPTS -Dcom.sun.management.jmxremote.authenticate=false"
	OPTS="$OPTS -Dcom.sun.management.jmxremote.port=1099"
	OPTS="$OPTS -Dcom.sun.management.jmxremote.rmi.port=1099"
	OPTS="$OPTS -Djava.rmi.server.hostname=${VM_HOST}"

	#Enables jpda remote debugging (same as "export JPDA_ADDRESS=8999 && export JPDA_TRANSPORT=dt_socket && ${TOMCAT_HOME}/bin/catalina.sh jpda run")
	OPTS="$OPTS -Xdebug -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8999 "
	#Alternative
	#OPTS="$OPTS -Xdebug --Xrunjdwp:server=y,transport=dt_socket,address=8999,suspend=n "

	#Exports configuration
	export CATALINA_OPTS="$CATALINA_OPTS $OPTS"
fi

#Enables custom jvm options 
if [ -n "$JAVA_OPTS" ]; then 
	export CATALINA_OPTS="$CATALINA_OPTS $JAVA_OPTS"
fi
	
echo "Starting catalina with options: $CATALINA_OPTS" >> $RUN_LOG

#PID file
PIDFILE="$(dirname $0)/liferay_pid"

# exit_handler() {
	# echo Stopping Tomcat and exiting...
	# ${TOMCAT_HOME}/bin/catalina.sh stop
	# exit 0
# }

# stop_handler() {
	# echo Stopping Tomcat...
	# ${TOMCAT_HOME}/bin/catalina.sh stop
# }

# #Trap signals	(does not work as expected)
# trap "exit_handler;" SIGHUP SIGINT SIGQUIT SIGTERM
# trap "stop_handler;" SIGUSR1

# #Saves PID
# echo "$$" > "$PIDFILE"
# #Launch catalina
# while true
# do
	# echo Starting Tomcat...
	# ${TOMCAT_HOME}/bin/catalina.sh run
	# #Sends self stop
	# kill -STOP $$
	# sleep 1
# done

#Launch catalina
echo Starting Tomcat... >> $RUN_LOG
while true
do
	#Saves PID
	echo "$$" > "$PIDFILE"
	/var/tomcat/bin/catalina.sh run
	if [ -e "$PIDFILE" ]; then
		echo "Stop requested. Exiting..."
		#Stop has been requested
		exit 0
	else
		while true
		do
			echo "Waiting for return of ${PIDFILE}..."
			if [ -e "$PIDFILE" ]; then
				#Restart has been requested
				break
			fi
			sleep 5
		done
	fi
done

