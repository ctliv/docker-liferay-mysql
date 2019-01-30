ARG LIFERAY_URL=https://sourceforge.net/projects/lportal/files/Liferay%20Portal/7.1.2%20GA3/liferay-ce-portal-tomcat-7.1.2-ga3-20190107144105508.7z

FROM debian:stable-slim as liferay-setup

MAINTAINER Cristiano Toncelli <ct.livorno@gmail.com>

ARG LIFERAY_URL

# Install packages
RUN apt-get update && \
	apt-get install -y curl dtrx && \
	apt-get clean
	
# Install liferay
ENV SCRIPT_HOME=/opt/script \
    SSL_HOME=/opt/ssl
RUN cd /tmp && \
	curl -o "${LIFERAY_URL##*/}" -k -L -C - "${LIFERAY_URL}" && \
	dtrx -n "${LIFERAY_URL##*/}" && \
	rm "${LIFERAY_URL##*/}" && \
	mv $(ls -d /tmp/liferay*/liferay*) /opt && \
	mkdir -p $(ls -d /opt/liferay*)/deploy && \
	mkdir -p ${SCRIPT_HOME} && \
	mkdir -p ${SSL_HOME}

# Add configuration files
COPY conf tmp/conf
# Move configuration files
RUN mv /tmp/conf/liferay/* $(ls -d /opt/liferay*) && \
	mv /tmp/conf/log4j/* $(ls -d /opt/liferay*/tomcat*)/webapps/ROOT/WEB-INF/classes/META-INF/ && \
	mv /tmp/conf/tomcat/* $(ls -d /opt/liferay*/tomcat*)/conf

# Add startup scripts
COPY script/* ${SCRIPT_HOME}/
RUN chmod +x ${SCRIPT_HOME}/*.sh
	
#######################################################
FROM debian:stable-slim

COPY --from=liferay-setup --chown=root:root /opt/ /opt/
	
# Install packages (for mkdir see: https://github.com/debuerreotype/docker-debian-artifacts/issues/24)
RUN mkdir -p /usr/share/man/man1 && \
	apt-get update && \
	apt-get install -y openjdk-8-jdk-headless openssh-server && \
	apt-get clean
	
ENV SCRIPT_HOME=/opt/script \
    SSL_HOME=/opt/ssl \
	SSL_PWD=changeit
	
# Change root password
# Export TERM as "xterm"
# Add variables to global profile
# Add symlinks to HOME dirs for easy access
RUN echo "root:Docker!" | chpasswd && \
    echo -e "\nexport TERM=xterm" >> ~/.bashrc && \
	echo >> /etc/profile && \
	echo "export LIFERAY_HOME=$(ls -d /opt/liferay*)" >> /etc/profile && \
	echo "export TOMCAT_HOME=$(ls -d /opt/liferay*/tomcat*)" >> /etc/profile && \
	echo "export SCRIPT_HOME=$SCRIPT_HOME" >> /etc/profile && \
	echo "export SSL_HOME=$SSL_HOME" >> /etc/profile && \
	echo "export SSL_PWD=$SSL_PWD" >> /etc/profile && \
	ln -s $(ls -d /opt/liferay*) /var/liferay && \
	ln -s $(ls -d /opt/liferay*/tomcat*) /var/tomcat

# Preparation for first execution:
# - Add liferay.home property to portal-ext.properties
# - Substitute environment variables in server.xml
# - Generate untrusted certificate for localhost in PKCS12 (open) format...
RUN echo "liferay.home=$(ls -d /opt/liferay*)" >> $(ls -d /opt/liferay*)/portal-ext.properties && \
	sed -i 's@${SSL_HOME}@'"${SSL_HOME}"'@' $(ls -d /opt/liferay*/tomcat*)/conf/server.xml && \
	sed -i 's@${SSL_PWD}@'"${SSL_PWD}"'@' $(ls -d /opt/liferay*/tomcat*)/conf/server.xml && \
	keytool -genkey -alias tomcat -keyalg RSA -storepass ${SSL_PWD} -keypass ${SSL_PWD} -dname "CN=CT, OU=Dev, O=CtLiv, L=LI, ST=LI, C=IT" -keystore ${SSL_HOME}/.keystore -storetype pkcs12

# Ports
EXPOSE 8080 8443

# EXEC
CMD ["/opt/script/run.sh"]
