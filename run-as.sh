#!/bin/bash
docker run --name lep-as -p 80:8080 -p 443:8443 -p 2222:22 -p 1099:1099 -p 8999:8999 --link lep-db -e LIFERAY_DEBUG=1 -v /$(dirname $(readlink -f $0))/deploy-run:/var/liferay/deploy -v /$(dirname $(readlink -f $0))/../rainbow/rainbow-db/db:/opt/data $@ -d ctliv/liferay:6.2
