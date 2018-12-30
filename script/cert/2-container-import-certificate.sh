#!/bin/bash

scriptreal=$(realpath "$0")
scriptabs=$(dirname "$scriptreal")
scriptdir=$(dirname "$0")
scriptname=$(basename "$0")
scriptext="${scriptname##*.}"

showhelp () {
	echo
	echo "USAGE: $scriptname hostname"
	echo
	exit 1
}

if [ $# -ne 1 ]; then
	echo "Illegal number of parameters"
    showhelp
fi

hostname="$1"

if [ ! -d /etc/letsencrypt/live/${hostname} ]; then
	echo "Unable to detect certificate issued by certbot in:"
	echo "  /etc/letsencrypt/live/${hostname}"
    exit 1
fi

#Stop Tomcat
${SCRIPT_HOME}/stop.sh
sleep 10

#Rename default keystore
mv ${SSL_HOME}/.keystore ${SSL_HOME}/.keystore.org

#Create keystore "cert_and_key.p12" from certbot generated certificate
openssl pkcs12 -export -in /etc/letsencrypt/live/${hostname}/cert.pem -inkey /etc/letsencrypt/live/${hostname}/privkey.pem -out ${SSL_HOME}/cert_and_key.p12 -passout pass:${SSL_PWD} -name tomcat -CAfile /etc/letsencrypt/live/${hostname}/chain.pem -caname root
 
#Import keystore "cert_and_key.p12" and saves as ".keystore" in pkcs12 format
keytool -importkeystore -srckeystore ${SSL_HOME}/cert_and_key.p12 -srcstoretype pkcs12 -srcstorepass ${SSL_PWD} -alias tomcat -destkeystore ${SSL_HOME}/.keystore -deststoretype pkcs12 -deststorepass ${SSL_PWD} -destkeypass ${SSL_PWD}

#Convert ".keystore" in pkcs12 format
#keytool -importkeystore -srckeystore ${SSL_HOME}/.keystore -srcstorepass ${SSL_PWD} -destkeystore ${SSL_HOME}/.keystore -deststoretype pkcs12 -deststorepass ${SSL_PWD}
 
#Import certificate chain
keytool -import -trustcacerts -alias root -file /etc/letsencrypt/live/${hostname}/chain.pem -keystore ${SSL_HOME}/.keystore -storepass ${SSL_PWD}

#Restart Tomcat
${SCRIPT_HOME}/restart.sh

