docker rm lep-as lep-db
$(dirname $(realpath $0))/run-db.sh
$(dirname $(realpath $0))/run-as.sh
