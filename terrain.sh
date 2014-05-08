#!/bin/bash

# if data is in D:/mapdata/work and source is in D:/src/map/ata, run within Docker linux with:

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
LIBDIR=$DIR/lib
DATA=/media/sf_ddrive/mapdata/work

if [ $(uname) != 'Linux' ]; then
	echo "run this inside Ubuntu-Docker"
	exit 1
fi

# USERNAME and PASS is missing from start.sh in helmi03/docker-postgis
PGDOCKER=ataz/postgis

NAME=baranya
BBOX=17.5,46.4,18.85,45.7

rm $DATA/$NAME-contour.*
docker run -v /tmp:/tmp -v $DATA:/data -v $LIBDIR:/src homme/gdal /src/terrain-sub.sh /data/srtm.tif /data/$NAME $BBOX

mkdir -p $HOME/$NAME-pgdata

$LIBDIR/start-pgis-db.sh $NAME

docker run --link $NAME-pgis:db ataz/postgis sh -c "echo 'DROP TABLE contourlines;' | psql-link"

docker run --link $NAME-pgis:db -v $DATA:/data ataz/postgis sh -c "shp2pgsql -c -D -s EPSG:3857 /data/$NAME-contour contourlines | psql-link -q"

echo "Finished. Postgres port is 5432"
