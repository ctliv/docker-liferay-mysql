docekr rm lep-as lep-db
docker run --name lep-db -p 3306:3306 -e MYSQL_ROOT_PASSWORD=adminpwd -e MYSQL_USER=lportal -e MYSQL_PASSWORD=lportal -e MYSQL_DATABASE=lportal -d mysql:5.7
docker run --name lep-as -p 80:8080 -p 443:8443 -p 2222:2222 -p 1099:1099 -p 8999:8999 --link lep-db -e LIFERAY_DEBUG=1 -e VM_HOST=lep-dynu.com -d ctliv/liferay:6.2