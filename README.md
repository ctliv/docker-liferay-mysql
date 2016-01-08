# Docker image for Liferay 6.2.4 GA5 on Tomcat with mysql DB (using two separate containers)

The image is available in docker registry: https://hub.docker.com/r/ctliv/liferay/

##Pulling:
```
docker pull ctliv/liferay:6.2-GA5
```
##Launching using "docker run":
###Run mysql:
```
docker run --name lep-db -e MYSQL_ROOT_PASSWORD=admin -e MYSQL_USER=lportal -e MYSQL_PASSWORD=lportal -e MYSQL_DATABASE=lportal -d mysql:5.7
```
To enable remote connection to db add option:
```
-p 3306:3306
```
###Run Liferay:
```
docker run --name lep-as -p 80:8080 --link lep-db:mysql-db -d ctliv/liferay:6.2-GA5
```
To enable development mode (SSH daemon + JMX monitoring + dt_socket debugging) add options:
```
-e LIFERAY_DEBUG=1 -p 2222:22 -p 1099:1099 -p 8999:8999 
```
If docker daemon does not run on localhost (e.g.: VirtualBox), JMX monitoring needs option:
```
-e VM_HOST=<docker daemon hostname>
```
To mount liferay deploy directory on localhost add:
```
-v /absolute/path/to/local/folder:/var/liferay/deploy
```
##Launching using "docker-compose":

###Clone git repository
```
git clone https://github.com/ctliv/docker-liferay-mysql
cd docker-liferay-mysql
```
###Run (production mode):
```
docker-compose -f docker-compose-prod.yml up
```
###Run (development mode):
```
docker-compose up
```
##Use:
Point browser to docker machine ip (port 80)