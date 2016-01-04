#!/bin/bash

#On first run, if debug is enabled, launch jstatd and add jvm remote debug hook
if [ $LIFERAY_RUN -eq 0 ]; && [ $LIFERAY_DEBUG -eq 1 ]; then
	#Adds remote debug hook to tomcat java configuration
	/bin/echo -e '\nCATALINA_OPTS="$CATALINA_OPTS -agentlib:jdwp=transport=dt_socket,server=y,suspend=n,address=8999"' >> ${TOMCAT_HOME}/bin/setenv.sh
	#Launch jstatd for remote JVM inspection using JVisualVM
	jstatd -p 18099 -J-Djava.security.policy=/opt/script/jstatd.all.policy &
fi

#Increment run count
export LIFERAY_RUN=$((LIFERAY_RUN + 1))

#${TOMCAT_HOME}/bin/catalina.sh