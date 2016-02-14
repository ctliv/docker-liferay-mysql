Liferay 6.2.4 GA6 on Tomcat with mysql DB (two containers)
==========================================================

Image available in docker registry: https://hub.docker.com/r/ctliv/liferay/

## Pulling:

```
docker pull ctliv/liferay:6.2
```

## Launching using "docker run":

```
# Run mysql:
docker run --name lep-db -e MYSQL_ROOT_PASSWORD=admin -e MYSQL_USER=lportal -e MYSQL_PASSWORD=lportal -e MYSQL_DATABASE=lportal -d mysql:5.7
# To enable remote connection add option:
#     -p 3306:3306

# Run liferay:
docker run --name lep-as -p 80:8080 -p 443:8443 --link lep-db -d ctliv/liferay:6.2
# To enable development mode add options (includes SSH daemon + JMX monitoring + dt_socket debugging) add options:
#     -e LIFERAY_DEBUG=1 -p 2222:22 -p 1099:1099 -p 8999:8999
# If docker daemon does not run on localhost (e.g.: VirtualBox), JMX monitoring needs option: 
#     -e VM_HOST=<docker daemon hostname>
# To mount liferay deploy directory locally add: 
#     -v /absolute/path/to/local/folder:/var/liferay/deploy
```

## Launching using "docker-compose":

```
git clone https://github.com/ctliv/docker-liferay-mysql
cd docker-liferay-mysql
docker-compose up
# For production mode use: docker-compose -f docker-compose-prod.yml up
```

## Use:

Point browser to docker machine ip (port 80 or port 443)