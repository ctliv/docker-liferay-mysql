# Liferay 6.2.4 GA5 on Tomcat
#

FROM ubuntu:14.04

MAINTAINER Cristiano Toncelli <ct.livorno@gmail.com>

# Install java
RUN apt-get update && \
    apt-get install -y openjdk-7-jdk && \
	export JAVA_HOME=/usr/lib/jvm/java-7-openjdk && \
	export PATH=$PATH:$JAVA_HOME/bin && \
	apt-get clean

## Set JAVA_HOME
# ENV JAVA_HOME /opt/java
	
# Install curl+unzip
RUN apt-get update && \
	apt-get install -y curl \
	unzip && \
	apt-get clean
	
# Install liferay
ENV Liferay liferay-portal-tomcat-6.2-ce-ga5
ENV Tomcat tomcat-7.0.42
RUN curl -O -s -k -L -C - http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/6.2.4%20GA5/${Liferay}-20151119152357409.zip && \
	unzip ${Liferay}-20151119152357409.zip -d /opt && \
	rm ${Liferay}-20151119152357409.zip
	
# Remove Liferay sample site/application
RUN rm -fr /opt/${Liferay}/${Tomcat}/webapps/welcome-theme

# add config for bdd
RUN /bin/echo -e '\nCATALINA_OPTS="$CATALINA_OPTS -Dexternal-properties=portal-bd-${DB_TYPE}.properties"' >> /opt/liferay-portal-6.2-ce-ga4/tomcat-7.0.42/bin/setenv.sh

# add configuration liferay file
ADD conf/portal-bundle.properties /opt/${Liferay}/portal-bundle.properties
ADD conf/portal-bd-MYSQL.properties /opt/${Liferay}/portal-bd-MYSQL.properties
ADD conf/portal-bd-POSTGRESQL.properties /opt/${Liferay}/portal-bd-POSTGRESQL.properties

# volumes
VOLUME ["/var/liferay-home", "/opt/${Liferay}/"]

# Ports
EXPOSE 8080

# EXEC
CMD ["run"]
ENTRYPOINT ["/opt/${Liferay}/${Tomcat}/bin/catalina.sh start && tail -f /opt/${Liferay}/${Tomcat}/logs/catalina.out"]
