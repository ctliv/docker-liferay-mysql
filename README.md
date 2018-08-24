Liferay CE on Tomcat with MySql DB
==================================

Docker registry: https://hub.docker.com/r/ctliv/liferay/

## Tags (Liferay versions):

```
ctliv/liferay:latest 
ctliv/liferay:7_1_0-GA1
ctliv/liferay:7_0_6-GA7
ctliv/liferay:7_0_5-GA6
ctliv/liferay:7_0_4-GA5
ctliv/liferay:7_0_3-GA4
ctliv/liferay:7_0_2-GA3
ctliv/liferay:7_0_1-GA2
ctliv/liferay:7_0_0-GA1
ctliv/liferay:6_2_5-GA6
```

## Git repo:

```
git clone https://github.com/ctliv/docker-liferay-mysql
cd docker-liferay-mysql
```

## Use:
See: https://docs.docker.com/compose/reference/overview/

### Launch latest version:
```
docker-compose up -d
```

### Launch specific version (<tag>):
```
docker-compose -f docker-compose-<tag>.yml up -d
``` 

### Lifecycle commands
```
docker-compose stop
docker-compose start
docker-compose restart
```

### Stop and remove containers
```
docker-compose down
```

## Info:

- Prepend "sudo" to command, if needed
- Point browser to docker machine ip (either port 80 or port 443)
- (Liferay 6) Deploy wars in "deploy" folder
- (Liferay 7) Deploy osgi bundles in "deploy" folder
- (Liferay 7) Remove installed osgi bundles from "modules" folder
- Add custom files to "data" folder (mapped as "/opt/data" inside lep-as)

