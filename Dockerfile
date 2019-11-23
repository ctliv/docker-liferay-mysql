ARG LIFERAY_URL=https://sourceforge.net/projects/lportal/files/Liferay%20Portal/7.2.1%20GA2/liferay-ce-portal-tomcat-7.2.1-ga2-20191111141448326.7z
ARG JDK_URL=https://github.com/AdoptOpenJDK/openjdk11-binaries/releases/download/jdk-11.0.3%2B7/OpenJDK11U-jdk_x64_linux_hotspot_11.0.3_7.tar.gz
ARG SCRIPT_HOME=/opt/script
ARG TLS_HOME=/opt/tls
ARG TLS_PWD=changeit

FROM debian:stable-slim as liferay-setup

MAINTAINER Cristiano Toncelli <ct.livorno@gmail.com>

ARG LIFERAY_URL
ARG JDK_URL
ARG SCRIPT_HOME
ARG TLS_HOME

# Install packages
RUN apt-get update && \
	apt-get install -y curl dtrx && \
	apt-get clean
	
# Install liferay
RUN cd /tmp && \
	rm -fr * && \
	curl -o "${LIFERAY_URL##*/}" -k -L -C - "${LIFERAY_URL}" && \
	dtrx -n "${LIFERAY_URL##*/}" && \
	rm "${LIFERAY_URL##*/}" && \
	mv $(ls -d /tmp/liferay*/liferay*) /opt && \
	ln -s $(ls -d /opt/liferay*) /var/liferay && \
	ln -s $(ls -d /opt/liferay*/tomcat*) /var/tomcat && \
	mkdir -p /var/liferay/deploy && \
	mkdir -p ${SCRIPT_HOME} && \
	mkdir -p ${TLS_HOME}

# Add configuration files
COPY conf tmp/conf
# Move configuration files
RUN mv /tmp/conf/liferay/* /var/liferay && \
	mv /tmp/conf/log4j/* /var/tomcat/webapps/ROOT/WEB-INF/classes/META-INF/ && \
	mv /tmp/conf/tomcat/* /var/tomcat/conf

# Add startup scripts
COPY script/* ${SCRIPT_HOME}/
RUN chmod -R +x ${SCRIPT_HOME}/*.sh

# Install Java
RUN cd /tmp && \
	rm -fr * && \
	curl -o "${JDK_URL##*/}" -k -L -C - "${JDK_URL}" && \
	dtrx -n "${JDK_URL##*/}" && \
	rm "${JDK_URL##*/}" && \
	mkdir -p /usr/lib/jvm && \
	mv */* /usr/lib/jvm

#######################################################
FROM debian:stable-slim

# Allow non-free packages in apt-get (needed if ttf-mscorefonts-installer have to be installed)
#RUN sed -i 's@ main@ main non-free contrib@' /etc/apt/sources.list

# Install packages (for mkdir see: https://github.com/debuerreotype/docker-debian-artifacts/issues/24)
RUN mkdir -p /usr/share/man/man1 && \
	apt-get update && \
	apt-get install -y openssh-server libfontconfig1 cron && \
	apt-get clean

COPY --from=liferay-setup --chown=root:root /opt/ /opt/
COPY --from=liferay-setup --chown=root:root /usr/lib/jvm/ /usr/lib/jvm/
	
ARG SCRIPT_HOME
ARG TLS_HOME
ARG TLS_PWD
	
# Change root password
# Export TERM as "xterm"
# Add variables to global profile
# Add symlinks to HOME dirs for easy access
# Registers java in update-alternatives
# Add cleanup script to crontab
RUN echo "root:Docker!" | chpasswd && \
    echo -e "\nexport TERM=xterm" >> ~/.bashrc && \
	echo >> /etc/profile && \
	echo "export LIFERAY_HOME=$(ls -d /opt/liferay*)" >> /etc/profile && \
	echo "export TOMCAT_HOME=$(ls -d /opt/liferay*/tomcat*)" >> /etc/profile && \
	echo "export SCRIPT_HOME=$SCRIPT_HOME" >> /etc/profile && \
	echo "export TLS_HOME=$TLS_HOME" >> /etc/profile && \
	echo "export TLS_PWD=$TLS_PWD" >> /etc/profile && \
	ln -s $(ls -d /opt/liferay*) /var/liferay && \
	ln -s $(ls -d /opt/liferay*/tomcat*) /var/tomcat && \
	for x in $(ls -d /usr/lib/jvm/*)/bin/*; do update-alternatives --install /usr/bin/$(basename $x) $(basename $x) $x 100; done && \
	for x in $(ls -d /usr/lib/jvm/*)/bin/*; do update-alternatives --set $(basename $x) $x; done && \
	crontab /opt/script/crontab.txt

# Preparation for first execution:
# - Add liferay.home property to portal-ext.properties
# - Substitute environment variables in server.xml
# - Generate untrusted certificate for localhost in PKCS12 (open) format...
RUN echo "liferay.home=$(ls -d /opt/liferay*)" >> /var/liferay/portal-ext.properties && \
	sed -i 's@${TLS_HOME}@'"${TLS_HOME}"'@' /var/tomcat/conf/server.xml && \
	sed -i 's@${TLS_PWD}@'"${TLS_PWD}"'@' /var/tomcat/conf/server.xml && \
	keytool -genkey -alias tomcat -keyalg RSA -storepass ${TLS_PWD} -keypass ${TLS_PWD} -dname "CN=CT, OU=Dev, O=CtLiv, L=LI, ST=LI, C=IT" -keystore ${TLS_HOME}/.keystore -storetype pkcs12

# Ports
EXPOSE 8080 8443 22 1099 8999 11311

# EXEC
# Waits max 30 secs for DB to be up, then runs
CMD ["/opt/script/wait-for-it.sh", "lep-db:3306", "-t", "30", "--", "/opt/script/run.sh"]
