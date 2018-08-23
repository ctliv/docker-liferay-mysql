Liferay CE on Tomcat with MySql DB
==================================

Docker registry: https://hub.docker.com/r/ctliv/liferay/

## Tags:

```
ctliv/liferay:7.0
ctliv/liferay:6CE
```

## Git repo (default branch: 7.0):

```
git clone https://github.com/ctliv/docker-liferay-mysql
cd docker-liferay-mysql
```

## Use:

```
#First launch
docker-compose up

#Stop
docker-compose stop

#Start
docker-compose start

#Stop and delete
docker-compose down
```

## Info:

- Prepend "sudo" to command, if needed
- Point browser to docker machine ip (either port 80 or port 443)
- (7.0+) Deploy bundles to "deploy" folder
- (7.0+) Remove installed bundles from "modules" folder
- Add custom files to "data" folder (mapped as "/opt/data" inside lep-as)
- Custom script "boot.sh" provided as alternative to docker-compose

