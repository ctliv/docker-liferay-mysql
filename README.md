Liferay (latest 6.2 or 7.0) on Tomcat with mysql DB (two containers)
====================================================================

Image available in docker registry: https://hub.docker.com/r/ctliv/liferay/

## Images:

```
ctliv/liferay:6.2
ctliv/liferay:7.0
```

## Scripts:

```
git clone https://github.com/ctliv/docker-liferay-mysql
git checkout 7.0    (or 6.2)
cd docker-liferay-mysql
```

## First launch:

```
docker-compose up
```
or
```
boot.sh -adc
```

## Gracefully stopping and starting containers:

```
docker-compose stop
docker-compose start
```
or
```
stop.sh
start.sh
```

## Use:

- Prepend "sudo" to command, if needed
- Point browser to docker machine ip (port 80 or port 443)
- Deploy bundles to "deploy" folder
- Remove installed bundles from "modules" folder
- Add custom files to "data" folder

