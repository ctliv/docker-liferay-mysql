ARG LIFERAY_URL=https://sourceforge.net/projects/lportal/files/Liferay%20Portal/7.1.1%20GA2/liferay-ce-portal-tomcat-7.1.1-ga2-20181112144637000.7z
ARG LIFERAY_EXT=7z
ARG LIFERAY_DIR=liferay-ce-portal-7.1.1-ga2
FROM debian:stable-slim as liferay-setup

MAINTAINER Cristiano Toncelli <ct.livorno@gmail.com>

ARG LIFERAY_URL
ARG LIFERAY_EXT
ARG LIFERAY_DIR

# Install packages
RUN apt-get update && \
	apt-get install -y curl dtrx && \
	apt-get clean
	
# Install liferay
ENV LIFERAY_HOME=/opt/${LIFERAY_DIR} \
	SCRIPT_HOME=/opt/script \
    SSL_HOME=/opt/ssl
RUN cd /tmp && \
	curl -o ${LIFERAY_DIR}.${LIFERAY_EXT} -k -L -C - \
	"${LIFERAY_URL}" && \
	dtrx -n ${LIFERAY_DIR}.${LIFERAY_EXT} && \
	mv ${LIFERAY_DIR} /opt && \
	rm ${LIFERAY_DIR}.${LIFERAY_EXT} && \
	mkdir -p ${LIFERAY_HOME}/deploy && \
	mkdir -p ${SCRIPT_HOME} && \
	mkdir -p ${SSL_HOME}

# Add configuration files
COPY conf tmp/conf
# Move configuration files
RUN mv /tmp/conf/liferay/* ${LIFERAY_HOME}/ && \
	mv /tmp/conf/log4j/* $(ls -d /opt/${LIFERAY_DIR}/tomcat*)/webapps/ROOT/WEB-INF/classes/META-INF/ && \
	mv /tmp/conf/tomcat/* $(ls -d /opt/${LIFERAY_DIR}/tomcat*)/conf

# Add startup scripts
COPY script/* ${SCRIPT_HOME}/
RUN chmod +x ${SCRIPT_HOME}/*.sh
	
#######################################################
FROM debian:stable-slim

ARG LIFERAY_DIR

COPY --from=liferay-setup --chown=root:root /opt/ /opt/
	
# Install packages (for mkdir see: https://github.com/debuerreotype/docker-debian-artifacts/issues/24)
RUN mkdir -p /usr/share/man/man1 && \
	apt-get update && \
	apt-get install -y openjdk-8-jdk-headless openssh-server && \
	apt-get clean
	
ENV LIFERAY_HOME=/opt/${LIFERAY_DIR} \
	SCRIPT_HOME=/opt/script \
    SSL_HOME=/opt/ssl \
	SSL_PWD=changeit
	
# Change root password
# Export TERM as "xterm"
# Add variables to global profile
# Add symlinks to HOME dirs for easy access
RUN echo "root:Docker!" | chpasswd && \
    echo -e "\nexport TERM=xterm" >> ~/.bashrc && \
	echo >> /etc/profile && \
	echo "export LIFERAY_HOME=/opt/${LIFERAY_DIR}" >> /etc/profile && \
	echo "export TOMCAT_HOME=$(ls -d /opt/${LIFERAY_DIR}/tomcat*)" >> /etc/profile && \
	echo "export SCRIPT_HOME=/opt/script" >> /etc/profile && \
	echo "export SSL_HOME=/opt/ssl" >> /etc/profile && \
	echo "export SSL_PWD=${SSL_PWD}" >> /etc/profile && \
	ln -s /opt/${LIFERAY_DIR} /var/liferay && \
	ln -s $(ls -d /opt/${LIFERAY_DIR}/tomcat*) /var/tomcat

# Preparation for first execution:
# - Add liferay.home property to portal-setup-wizard.properties
# - Substitute environment variables in server.xml
# - Generate untrusted certificate for localhost in PKCS12 (open) format...
RUN echo "liferay.home=$LIFERAY_HOME" >> ${LIFERAY_HOME}/portal-ext.properties && \
	sed -i 's@${SSL_HOME}@'"${SSL_HOME}"'@' $(ls -d /opt/${LIFERAY_DIR}/tomcat*)/conf/server.xml && \
	sed -i 's@${SSL_PWD}@'"${SSL_PWD}"'@' $(ls -d /opt/${LIFERAY_DIR}/tomcat*)/conf/server.xml && \
	keytool -genkey -alias tomcat -keyalg RSA -storepass ${SSL_PWD} -keypass ${SSL_PWD} -dname "CN=CT, OU=Dev, O=CtLiv, L=LI, ST=LI, C=IT" -keystore ${SSL_HOME}/.keystore -storetype pkcs12

# Ports
EXPOSE 8080 8443

# EXEC
CMD ["/opt/script/run.sh"]
