docker stop lep-as
docker rm lep-as
$(dirname $(readlink -f $0))/run-as.sh -e LIFERAY_NOWIZARD=1
