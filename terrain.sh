#!/bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
. $DIR/config.inc.sh

LIBDIR=$DIR/lib

if [ $(uname) != 'Linux' ]; then
	echo "run this inside Ubuntu-Docker"
	exit 1
fi

# USERNAME and PASS is missing from start.sh in helmi03/docker-postgis
PGDOCKER=ataz/postgis

if [[ $DEMSRC -nt $WORKDIR/$NAME-contour.shp ]]; then
	rm -f $WORKDIR/$NAME-contour.*
	docker run --rm \
		-v $(dirname $DEMSRC):/dem \
		-v $WORKDIR:/data -v $LIBDIR:/src \
		homme/gdal /src/terrain-sub.sh /dem/$(basename $DEMSRC) /data/$NAME $BBOX
fi

$LIBDIR/start-pgis-db.sh $NAME

docker run --rm -i --link $NAME-pgis:db $PGDOCKER psql-link <<< 'DROP TABLE IF EXISTS contours;'

docker run --rm --link $NAME-pgis:db -v $WORKDIR:/data $PGDOCKER sh -c "shp2pgsql -c -D -s EPSG:3857 /data/$NAME-contour contours | psql-link -q"

# create column "vis" based on elevation step
docker run --rm -i --link $NAME-pgis:db $PGDOCKER psql-link <<EOF
ALTER TABLE contours ADD COLUMN vis integer;
UPDATE contours SET vis = CASE
	WHEN (SELECT CAST(round(elev) AS integer))%500=0 THEN 8
	WHEN (SELECT CAST(round(elev) AS integer))%200=0 THEN 7
	WHEN (SELECT CAST(round(elev) AS integer))%100=0 THEN 6
	WHEN (SELECT CAST(round(elev) AS integer))%50=0 THEN 5
	WHEN (SELECT CAST(round(elev) AS integer))%20=0 THEN 4
	WHEN (SELECT CAST(round(elev) AS integer))%10=0 THEN 3
	WHEN (SELECT CAST(round(elev) AS integer))%5=0 THEN 2
	WHEN (SELECT CAST(round(elev) AS integer))%2=0 THEN 1
	ELSE 0
END;
EOF

echo "Finished. Postgres port is 5432"
