#!/bin/bash

NAME=$1
if [ -z $NAME ]; then
	echo "Directory/docker name argument missing" 2>&1
	exit 1
fi

# check if database server is running, start it if not
docker inspect --format='-' $NAME-pgis >/dev/null 2>&1 ||
	docker run -d -p 5432:5432 --name $NAME-pgis -v $HOME/$NAME-pgdata:/var/lib/postgresql ataz/postgis && sleep 2
