#!/bin/bash

NAME=$1
if [ -z $NAME ]; then
	echo "Directory/docker name argument missing" 2>&1
	exit 1
fi

# check if database server is running, create or start it if not
if ! docker inspect $NAME-pgis >/dev/null 2>&1; then
	docker run -d -p 5432:5432 --name $NAME-pgis -v $HOME/$NAME-pgdata:/var/lib/postgresql ataz/postgis && sleep 2
elif [ `docker inspect --format='{{.State.Running}}' $NAME-pgis` != 'true' ]; then
	docker start $NAME-pgis
fi
