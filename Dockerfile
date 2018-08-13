FROM ubuntu:xenial

MAINTAINER Cristiano Toncelli <ct.livorno@gmail.com>

# Users and groups
# RUN groupadd -r tomcat && useradd -r -g tomcat tomcat
RUN echo "root:Docker!" | chpasswd

# Install packages
RUN apt-get update && \
	apt-get install -y curl unzip ssh vim net-tools git telnet && \
	apt-get clean
	
# Export TERM as "xterm"
RUN echo -e "\nexport TERM=xterm" >> ~/.bashrc
	
# Install Java 8 JDK 
RUN apt-get update && \
    apt-get install -y openjdk-8-jdk && \
	apt-get clean
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV JRE_HOME=$JAVA_HOME/jre 
ENV PATH=$PATH:$JAVA_HOME/bin

# Install liferay
ENV LIFERAY_BASE=/opt
ENV LIFERAY_DIR=liferay-ce-portal-7.1.0-ga1
ENV TOMCAT_DIR=tomcat-9.0.6
ENV LIFERAY_HOME=${LIFERAY_BASE}/${LIFERAY_DIR}
ENV TOMCAT_HOME=${LIFERAY_HOME}/${TOMCAT_DIR}
RUN cd /tmp && \
	curl -o ${LIFERAY_DIR}.zip -k -L -C - \
	"https://sourceforge.net/projects/lportal/files/Liferay%20Portal/7.1.0%20GA1/liferay-ce-portal-tomcat-7.1.0-ga1-20180703012531655.zip" && \
	unzip ${LIFERAY_DIR}.zip -d /opt && \
	rm ${LIFERAY_DIR}.zip && \
	mkdir -p ${LIFERAY_HOME}/deploy && \
	mkdir -p ${LIFERAY_BASE}/script

# Add latest version of language files
#RUN mkdir ${TOMCAT_HOME}/webapps/ROOT/WEB-INF/classes/content
#ADD lang/* ${TOMCAT_HOME}/webapps/ROOT/WEB-INF/classes/content/

# Add symlinks to HOME dirs
RUN ln -fs ${LIFERAY_HOME} /var/liferay && \
	ln -fs ${TOMCAT_HOME} /var/tomcat
	
# Add configuration files to liferay home
ADD conf/* ${LIFERAY_HOME}/

# Add log4j custom configuration files
ADD logconf/* ${TOMCAT_HOME}/webapps/ROOT/WEB-INF/classes/META-INF/

# Add plugins to auto-deploy directory
ADD deploy-boot/* ${LIFERAY_HOME}/deploy/

# Add startup scripts
ADD script/* ${LIFERAY_BASE}/script/
RUN chmod +x ${LIFERAY_BASE}/script/*.sh

# Ports
EXPOSE 8080 8443

# EXEC
CMD ["/opt/script/start.sh"]
