$(dirname $0)/run-as-prod.sh -e LIFERAY_DEBUG=1 -p 2222:22 -p 1099:1099 -p 8999:8999 -e VM_HOST=vm-default -v $(dirname $0)/deploy-run:/var/liferay/deploy $@
