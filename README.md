# Docker image for liferay 6.2 on Tomcat with mysql DB (using two containers)

The image is available in docker registry: https://hub.docker.com/r/ctliv/liferay/

## Pull
```
docker pull ctliv/liferay:6.2-GA5
```

## Run
### Using docker-compose
```
docker-compose up
```
### Using docker run
```
docker run --name lep-db -e MYSQL_ROOT_PASSWORD=admin -e MYSQL_USER=lportal -e MYSQL_PASSWORD=lportal -e MYSQL_DATABASE=lportal -d mysql:5.7
docker run --name lep-as -p 80:8080 --link lep-db:mysql-db -d ctliv/liferay:6.2-GA5
```

## Use
Point browser to docker machine ip (port 80)
