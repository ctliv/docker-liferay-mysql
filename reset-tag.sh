if [[ "$1" == "" ]]; then
	echo "Usage: reset-tag <tagname>"
	exit
fi

git tag -d $1
git push --delete origin $1
git tag $1
git push origin $1