FROM ubuntu:xenial

MAINTAINER Cristiano Toncelli <ct.livorno@gmail.com>

# Users and groups
# RUN groupadd -r tomcat && useradd -r -g tomcat tomcat
RUN echo "root:Docker!" | chpasswd

# Set environment: curl unzip ssh vim
RUN apt-get update && \
	apt-get install -y curl unzip ssh vim net-tools && \
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
ENV LIFERAY_VER=liferay-portal-6.2-ce-ga6
ENV LIFERAY_HOME=${LIFERAY_BASE}/${LIFERAY_VER} 
ENV TOMCAT_VER=tomcat-7.0.62 
ENV TOMCAT_HOME=${LIFERAY_HOME}/${TOMCAT_VER} 
RUN cd /tmp && \
	curl -o ${LIFERAY_VER}.zip -k -L -C - \
	"http://sourceforge.net/projects/lportal/files/Liferay%20Portal/6.2.5%20GA6/liferay-portal-tomcat-6.2-ce-ga6-20160112152609836.zip" && \
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
EXPOSE 8080 8443

# EXEC
CMD ["/opt/script/start.sh"]
