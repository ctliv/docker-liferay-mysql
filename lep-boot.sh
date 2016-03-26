docker rm lep-as lep-db
$(dirname $(readlink -f $0))/run-db.sh
$(dirname $(readlink -f $0))/run-as.sh
