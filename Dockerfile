# Docker image for Liferay 6.2.4 GA5 on Tomcat with mysql DB (using two separate containers)
#
# The image is available in docker registry: https://hub.docker.com/r/ctliv/liferay/
#
# Pulling:
#
#      docker pull ctliv/liferay:6.2-GA5
#
# Launching using "docker run":
#
#   A) Run mysql:
#        docker run --name lep-db -e MYSQL_ROOT_PASSWORD=admin -e MYSQL_USER=lportal -e MYSQL_PASSWORD=lportal -e MYSQL_DATABASE=lportal -d mysql:5.7
#      To enable remote connection to db add option:
#        -p 3306:3306
#
#   B) Run Liferay:
#        docker run --name lep-as -p 80:8080 --link lep-db:mysql-db -d ctliv/liferay:6.2-GA5
#      To enable development mode (SSH daemon + JMX monitoring + dt_socket debugging) add options:
#        -e LIFERAY_DEBUG=1 -p 2222:22 -p 1099:1099 -p 8999:8999 
#      If docker daemon does not run on localhost (e.g.: VirtualBox), JMX monitoring needs option:
#        -e VM_HOST=<docker daemon hostname>
#      To mount liferay deploy directory on localhost add:
#        -v /absolute/path/to/local/folder:/var/liferay/deploy
#
# Launching using "docker-compose":
#
#   A) Clone git repository
#        git clone https://github.com/ctliv/docker-liferay-mysql
#        cd docker-liferay-mysql
#
#   B) Run (production mode):
#        docker-compose -f docker-compose-prod.yml up
#   -- or --
#   B) Run (development mode):
#        docker-compose up
#
# Use:
#
#   Point browser to docker machine ip (port 80)

FROM ubuntu:xenial

MAINTAINER Cristiano Toncelli <ct.livorno@gmail.com>

# Users and groups
# RUN groupadd -r tomcat && useradd -r -g tomcat tomcat
RUN echo "root:Docker!" | chpasswd

# Environment: install curl unzip ssh
RUN apt-get update && \
	apt-get install -y curl unzip ssh && \
	apt-get clean
	
# Install Java 8 JDK 
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
	apt-get clean
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV JRE_HOME=$JAVA_HOME/jre 
ENV PATH=$PATH:$JAVA_HOME/bin

# Install liferay (removing sample application "welcome-theme")
ENV LIFERAY_BASE=/opt
ENV LIFERAY_VER=liferay-portal-6.2-ce-ga5
ENV LIFERAY_HOME=${LIFERAY_BASE}/${LIFERAY_VER} 
ENV TOMCAT_VER=tomcat-7.0.62 
ENV TOMCAT_HOME=${LIFERAY_HOME}/${TOMCAT_VER} 
RUN cd /tmp && \
	curl -o ${LIFERAY_VER}.zip -k -L -C - \
	"http://downloads.sourceforge.net/project/lportal/Liferay%20Portal/6.2.4%20GA5/liferay-portal-tomcat-6.2-ce-ga5-20151119152357409.zip" && \
	unzip ${LIFERAY_VER}.zip -d /opt && \
	rm ${LIFERAY_VER}.zip && \
	rm -fr ${TOMCAT_HOME}/webapps/welcome-theme && \
	mkdir -p ${LIFERAY_HOME}/deploy && \
	mkdir -p ${LIFERAY_BASE}/script

# Add italian language files
RUN cd /tmp && \
	curl -o Language-ext_it-62x.zip -k -L -C - \
	"https://www.liferay.com/it/c/wiki/get_page_attachment?p_l_id=10436093&nodeId=10436223&title=File+Lingua+Italiana+Aggiornati&fileName=Language-ext_it-62x.zip" && \
	mkdir ${TOMCAT_HOME}/webapps/ROOT/WEB-INF/classes/content && \
	unzip Language-ext_it-62x.zip -d ${TOMCAT_HOME}/webapps/ROOT/WEB-INF/classes/content && \
	rm Language-ext_it-62x.zip

# Add symlinks to HOME dirs
RUN ln -fs ${LIFERAY_HOME} /var/liferay && \
	ln -fs ${TOMCAT_HOME} /var/tomcat
	
# Add configuration files to liferay home
ADD conf/* ${LIFERAY_HOME}/

# Add default plugins to auto-deploy directory
ADD deploy/* ${LIFERAY_HOME}/deploy/

# Add startup scripts
ADD script/* ${LIFERAY_BASE}/script/
RUN chmod +x ${LIFERAY_BASE}/script/*.sh

# Ports
EXPOSE 8080

# EXEC
CMD ["/opt/script/start.sh"]
