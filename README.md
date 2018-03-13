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
boot.sh -adc
```
or
```
docker-compose up
```

Notes:
- "boot.sh" with no parameters shows help
- Prepend "sudo" if needed

## Gracefully stopping and starting containers:

```
stop.sh
start.sh
```

Note:
- Prepend "sudo" if needed

## Use:

- Point browser to docker machine ip (port 80 or port 443)
- Deploy bundles to "deploy" folder
- Remove installed bundles from "modules" folder
- Add custom files to "data" folder

