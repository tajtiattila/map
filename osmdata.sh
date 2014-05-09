#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/config.inc.sh

LIBDIR=$DIR/lib

if [ $(uname) != 'Linux' ]; then
	echo "run this inside Ubuntu-Docker"
	exit 1
fi

if [[ $OSMSRC -nt $WORKDIR/$NAME-clip.osm.pbf ]]; then
	echo "Clipping pbf"
	docker run --rm -i -v $(dirname $OSMSRC):/src -v $WORKDIR:/data ataz/osmtools sh -c "osmconvert /src/$(basename $OSMSRC) --drop-author -b=$BBOX -o=/data/$NAME-clip.osm.pbf"
fi

$LIBDIR/start-pgis-db.sh $NAME

echo "Running import"
docker run --rm -i --link $NAME-pgis:db -v $WORKDIR:/data ataz/osmtools sh -c "PGPASS=docker osm2pgsql -c -H \$DB_PORT_5432_TCP_ADDR -U docker -d gis --flat-nodes /tmp /data/$NAME-clip.osm.pbf"

echo "Done"
