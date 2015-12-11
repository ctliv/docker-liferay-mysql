# Liferay 6.2.4 GA5 on Tomcat
#

FROM ubuntu:14.04

MAINTAINER Cristiano Toncelli <ct.livorno@gmail.com>

# Create user and group
RUN groupadd -r tomcat && useradd -r -g tomcat tomcat

# Install java
RUN apt-get update && \
    apt-get install -y openjdk-7-jdk && \
	apt-get clean
ENV JAVA_HOME /usr/lib/jvm/java-7-openjdk-amd64
ENV PATH $PATH:$JAVA_HOME/bin
ENV JRE_HOME $JAVA_HOME/jre

# Install curl+unzip
RUN apt-get update && \
	apt-get install -y curl unzip && \
	apt-get clean
	
# Install liferay
ENV LIFERAY_VER=liferay-portal-6.2-ce-ga5
ENV LIFERAY_HOME=/opt/${LIFERAY_VER}
ENV TOMCAT_VER=tomcat-7.0.62 
ENV TOMCAT_HOME=${LIFERAY_HOME}/${TOMCAT_VER}
RUN cd /tmp && \
	curl -o ${LIFERAY_VER}.zip -k -L -C - \
	"http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/6.2.4%20GA5/liferay-portal-tomcat-6.2-ce-ga5-20151119152357409.zip" && \
	unzip ${LIFERAY_VER}.zip -d /opt && \
	rm ${LIFERAY_VER}.zip
	
# Remove Liferay sample application
RUN rm -fr ${TOMCAT_HOME}/webapps/welcome-theme

# Add italian language files
RUN cd /tmp && \
	curl -o Language-ext_it-62x.zip -k -L -C - \
	"https://www.liferay.com/it/c/wiki/get_page_attachment?p_l_id=10436093&nodeId=10436223&title=File+Lingua+Italiana+Aggiornati&fileName=Language-ext_it-62x.zip" && \
	mkdir ${TOMCAT_HOME}/webapps/ROOT/WEB-INF/classes/content && \
	unzip Language-ext_it-62x.zip -d ${TOMCAT_HOME}/webapps/ROOT/WEB-INF/classes/content && \
	rm Language-ext_it-62x.zip

## add config for bdd
#RUN /bin/echo -e '\nCATALINA_OPTS="$CATALINA_OPTS -Dexternal-properties=portal-db-mysql.properties"' >> ${TOMCAT_HOME}/bin/setenv.sh

## add configuration liferay file
#ADD conf/portal-bundle.properties ${LIFERAY_HOME}/portal-bundle.properties
#ADD conf/portal-bd-MYSQL.properties ${LIFERAY_HOME}/portal-bd-MYSQL.properties

## volumes
#VOLUME ["/var/liferay-home", "${LIFERAY_HOME}/"]

# Ports
EXPOSE 8080

## EXEC
#CMD ["run"]
#ENTRYPOINT ["${TOMCAT_HOME}/bin/catalina.sh start && tail -f ${TOMCAT_HOME}/logs/catalina.out"]
