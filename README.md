Liferay (latest 6.2 or 7.0) on Tomcat with mysql DB (two containers)
====================================================================

Image available in docker registry: https://hub.docker.com/r/ctliv/liferay/

## Pull with one of:

```
docker pull ctliv/liferay:6.2
docker pull ctliv/liferay:7.0
```

## Launch:

```
lep-boot.sh -adc
```

Note: lep-boot.sh with no parameters show usage synopsis
Note: docker compose ".yml" files not maintained, currently

## Gracefully stopping and starting:

```
lep-stop.sh
lep-start.sh
```

## Use:

Point browser to docker machine ip (port 80 or port 443)
