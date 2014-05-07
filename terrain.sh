#!/bin/bash

# if data is in D:/mapdata/work and source is in D:/src/map/ata, run within Docker linux with:

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
DATA=/media/sf_ddrive/mapdata/work

if [ $(uname) != 'Linux' ]; then
	echo "run this inside Ubuntu-Docker"
	exit 1
fi

# USERNAME and PASS is missing from start.sh in helmi03/docker-postgis
PGDOCKER=ataz/postgis

NAME=baranya
BBOX=17.5,46.4,18.85,45.7

#docker run -v /tmp:/tmp -v $DATA:/data -v $DIR:/src homme/gdal /src/terrain-sub.sh /data/srtm.tif /data/$NAME $BBOX

mkdir -p $HOME/$NAME-pgdata

docker inspect $NAME-pgis ||
	docker run -d -P --name $NAME-pgis -v $HOME/$NAME-pgdata:/var/lib/postgresql ataz/postgis && sleep 2

PGIS_IP=$(docker inspect --format='{{.NetworkSettings.IPAddress}}' $NAME-pgis)
echo "Postgres IP is $PGIS_IP"

docker run -v $DATA:/data ataz/postgis sh -c "shp2pgsql /data/$NAME-contour $NAME.contour | PGPASSWORD=docker psql -h $PGIS_IP -p 5432 postgres docker"

