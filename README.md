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
git clone https://github.com/ctliv/docker-liferay-mysqlù
cd docker-liferay-mysql
```

## First launch:

```
boot.sh -adc
```

Note: boot.sh with no parameters shows help
Note: docker compose ".yml" files not maintained, currently

## Gracefully stopping and starting containers:

```
stop.sh
start.sh
```

## Use:

# Point browser to docker machine ip (port 80 or port 443)

# Deploy bundles copying jars/wars to "deploy" folder
