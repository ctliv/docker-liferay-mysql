FROM ubuntu:bionic

MAINTAINER Cristiano Toncelli <ct.livorno@gmail.com>

# Users and groups
RUN echo "root:Docker!" | chpasswd
# RUN groupadd -r tomcat && useradd -r -g tomcat tomcat

# Install packages
RUN apt-get update && \
	apt-get install -y curl unzip ssh vim net-tools git telnet dtrx && \
	apt-get clean
	
# Export TERM as "xterm"
RUN echo -e "\nexport TERM=xterm" >> ~/.bashrc
	
# Install Java 8 JDK 
RUN apt-get update && \
	apt-get install -y openjdk-8-jdk && \
	apt-get clean
ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV JRE_HOME=$JAVA_HOME/jre
ENV	PATH=$PATH:$JAVA_HOME/bin

# Install liferay
ENV LIFERAY_BASE=/opt \
	LIFERAY_DIR=liferay-ce-portal-7.1.1-ga2 \
	TOMCAT_DIR=tomcat-9.0.10 \
	LIFERAY_EXT=7z
ENV LIFERAY_HOME=${LIFERAY_BASE}/${LIFERAY_DIR} \
    TOMCAT_HOME=${LIFERAY_HOME}/${TOMCAT_DIR} \
	SCRIPT_HOME=${LIFERAY_BASE}/script \
    SSL_HOME=${LIFERAY_BASE}/ssl \
	SSL_PWD=changeit
RUN cd /tmp && \
	curl -o ${LIFERAY_DIR}.${LIFERAY_EXT} -k -L -C - \
	"https://sourceforge.net/projects/lportal/files/Liferay%20Portal/7.1.1%20GA2/liferay-ce-portal-tomcat-7.1.1-ga2-20181112144637000.7z" && \
	dtrx ${LIFERAY_DIR}.${LIFERAY_EXT} && \
	mv ${LIFERAY_DIR} /opt && \
	rm ${LIFERAY_DIR}.${LIFERAY_EXT} && \
	mkdir -p ${LIFERAY_HOME}/deploy && \
	mkdir -p ${SCRIPT_HOME} && \
	mkdir -p ${SSL_HOME}
	
#Add variables to global profile
RUN echo >> /etc/profile && \
	echo "export JAVA_HOME=${JAVA_HOME}" >> /etc/profile && \
	echo "export JRE_HOME=${JRE_HOME}" >> /etc/profile && \
	echo "export LIFERAY_BASE=${LIFERAY_BASE}" >> /etc/profile && \
	echo "export LIFERAY_DIR=${LIFERAY_DIR}" >> /etc/profile && \
	echo "export TOMCAT_DIR=${TOMCAT_DIR}" >> /etc/profile && \
	echo "export LIFERAY_HOME=${LIFERAY_HOME}" >> /etc/profile && \
	echo "export TOMCAT_HOME=${TOMCAT_HOME}" >> /etc/profile && \
	echo "export SCRIPT_HOME=${SCRIPT_HOME}" >> /etc/profile && \
	echo "export SSL_HOME=${SSL_HOME}" >> /etc/profile && \
	echo "export SSL_PWD=${SSL_PWD}" >> /etc/profile

# Add latest version of language files (Liferay 6.2 only)
# RUN mkdir ${TOMCAT_HOME}/webapps/ROOT/WEB-INF/classes/content
# ADD lang/* ${TOMCAT_HOME}/webapps/ROOT/WEB-INF/classes/content/

# Add symlinks to HOME dirs
RUN ln -fs ${LIFERAY_HOME} /var/liferay && \
	ln -fs ${TOMCAT_HOME} /var/tomcat
	
# Add configuration files to liferay home
ADD conf/liferay/* ${LIFERAY_HOME}/

# Add log4j custom configuration files
ADD conf/log4j/* ${TOMCAT_HOME}/webapps/ROOT/WEB-INF/classes/META-INF/

# Add Tomcat configuration files
ADD conf/tomcat/* ${TOMCAT_HOME}/conf

# Add plugins to auto-deploy directory
# ADD deploy-build/* ${LIFERAY_HOME}/deploy/

# Add startup scripts
ADD script/* ${SCRIPT_HOME}
RUN chmod +x ${SCRIPT_HOME}/*.sh

# Ports
EXPOSE 8080 8443

# EXEC
ENTRYPOINT ["${SCRIPT_HOME}/run.sh"]
