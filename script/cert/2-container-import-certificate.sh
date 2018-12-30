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

if [ ! -d /etc/letsencrypt/live/${host} ]; then
	echo "Unable to detect certificate issued by certbot in:"
	echo "  /etc/letsencrypt/live/${host}"
    exit 1
fi

host="$1"

#Stop Tomcat
${SCRIPT_HOME}/stop.sh
sleep 5

#Rename default keystore
mv ${SSL_HOME}/.keystore ${SSL_HOME}/.keystore.org

#Create keystore "cert_and_key.p12" from certbot generated certificate
openssl pkcs12 -export -in /etc/letsencrypt/live/${host}/cert.pem -inkey /etc/letsencrypt/live/${host}/privkey.pem -out ${SSL_HOME}/cert_and_key.p12 -name tomcat -CAfile /etc/letsencrypt/live/${host}/chain.pem -caname root -passout ${SSL_PWD}
 
#Import keystore "cert_and_key.p12" and saves as ".keystore" in pkcs12 format
keytool -importkeystore -srckeystore ${SSL_HOME}/cert_and_key.p12 -srcstoretype pkcs12 -srcstorepass ${SSL_PWD} -alias tomcat -destkeystore ${SSL_HOME}/.keystore -deststoretype pkcs12 -deststorepass ${SSL_PWD} -destkeypass ${SSL_PWD}

#Convert ".keystore" in pkcs12 format
#keytool -importkeystore -srckeystore ${SSL_HOME}/.keystore -srcstorepass ${SSL_PWD} -destkeystore ${SSL_HOME}/.keystore -deststoretype pkcs12 -deststorepass ${SSL_PWD}
 
#Import certificate chain
keytool -import -trustcacerts -alias root -file /etc/letsencrypt/live/${host}/chain.pem -keystore ${SSL_HOME}/.keystore -storepass ${SSL_PWD}

#Restart Tomcat
/opt/script/restart.sh

