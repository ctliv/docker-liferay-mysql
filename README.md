Liferay CE (latest 6.2 or 7.0) on Tomcat with MySql DB (two containers)
=======================================================================

Docker registry: https://hub.docker.com/r/ctliv/liferay/

## Tags:

```
ctliv/liferay:6.2
ctliv/liferay:7.0
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
- Point browser to docker machine ip (port 80 or port 443)
- Deploy bundles to "deploy" folder
- Remove installed bundles from "modules" folder
- Add custom files to "data" folder (mapped as "/opt/data" inside lep-as)
- Custom script "boot.sh" is provided is alternative to docker-compose

