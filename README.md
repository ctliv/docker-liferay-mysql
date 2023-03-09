Liferay CE on Tomcat with MySQL DB
==================================

# ** DISCONTINUED ** 

## Registry:

https://hub.docker.com/r/ctliv/liferay

## Usage:

```
git clone https://github.com/ctliv/docker-liferay-mysql

cd docker-liferay-mysql

docker-compose up -d
```

#### URL:

- http://localhost
- https://localhost

## Info:

- Deploy osgi bundles in "deploy" folder

- Uninstall osgi bundles removing from "modules" folder

- "data" folder is mapped as "/opt/data" in container "lep-as"

- Docker compose reference: https://docs.docker.com/compose/reference/overview/

