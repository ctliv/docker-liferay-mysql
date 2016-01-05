#!/bin/bash

#Reads LIFERAY_RUN
FILE=$(dirname $0)/liferay_runs
if [[ -e $FILE ]]; then
	LIFERAY_RUN=$(cat $FILE)
fi

#Increment and save run count
LIFERAY_RUN=$((LIFERAY_RUN + 1))
echo $LIFERAY_RUN > $FILE

##On first run, if debug is enabled, launch jstatd and add jvm remote debug hook
#if [[ $LIFERAY_RUN -eq 0 && $LIFERAY_DEBUG -eq 1 ]]; then
#	#Adds remote debug hook to tomcat java configuration
#	/bin/echo -e '\nCATALINA_OPTS="$CATALINA_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8999"' >> ${TOMCAT_HOME}/bin/setenv.sh
#fi

if [[ $LIFERAY_DEBUG -eq 1 ]]; then
	#Creates policy file
	policy=$(dirname $0)/jstatd.all.policy
	echo "grant codebase \"file:${JAVA_HOME}/lib/tools.jar\" {" > $policy
	echo "  permission java.security.AllPermission;" >> $policy
	echo "};" >> $policy

	#Launch jstatd for remote JVM inspection using JVisualVM
	jstatd -J-Djava.security.policy=$(dirname $0)/jstatd.all.policy &
	
	#Launch catalina (with debugging)
	export JPDA_ADDRESS=8999
	export JPDA_TRANSPORT=dt_socket
	${TOMCAT_HOME}/bin/catalina.sh jpda run
else
	#Launch catalina
	${TOMCAT_HOME}/bin/catalina.sh run
fi

#Launch tomcat
#${TOMCAT_HOME}/bin/catalina.sh run
